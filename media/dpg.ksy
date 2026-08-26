meta:
  id: dpg
  file-extension: dpg
  endian: le
  title: Nintendo DS DPG (nDs-mPeG)
doc: |
  The video container MoonShell plays on the Nintendo DS: an MPEG-1 video
  elementary stream and an MP2 audio elementary stream stored side by
  side (not multiplexed together -- a player jumps between two cursors,
  as mobipeg's own demuxer comment puts it), with a small header saying
  where each begins. Five versions exist, each adding fields to the end
  of the previous one's header rather than changing what came before:

  * DPG0/DPG1 -- 0x24-byte header (DPG1 adds nothing to the byte layout,
    only stereo audio support in the player).
  * DPG2/DPG3 -- 0x30 bytes, adding a GOP index location/size and a pixel
    format byte (DPG3 likewise adds nothing to the layout itself).
  * DPG4 -- 0x34 bytes, adding a 4-byte `THM0` marker, followed
    immediately by a fixed-size raw thumbnail (256x192 16-bit pixels, no
    image header of its own) before the audio/video data begins.

  There has never been an official specification; mobipeg's encoder and
  decoder both follow dpg4x, the closest thing to a reference tool, and
  this definition follows mobipeg. Two details dpg4x itself does not
  document, and which this definition states as mobipeg's own choice
  rather than a settled fact: DPG2+'s fractional frame rate encoding
  (8.8 fixed point, confirmed against a real generated file below rather
  than any outside source), and the GOP index entry contents (a plain
  4-byte little-endian offset, relative to the video stream's own start,
  of each `0x000001B8` GOP start code found by scanning the encoded video
  -- MoonShell needs this because MPEG-1 has no seek table of its own,
  and a decoder can only resume cleanly from a GOP boundary).

  ## Validated against

  No real MoonShell-authored DPG file was available on this machine --
  DPG is a homebrew-only format, never used by a retail title, so unlike
  most of this batch there is no disc or channel dump to check against.
  In its place: three files mobipeg's own muxer produced, one per header
  generation (`dpg_version 0`, `2`, `4`), checked field for field against
  a byte-level dump, and -- independently of trusting the muxer's own
  arithmetic -- the version-2 file's GOP index was recomputed from
  scratch in Python by scanning its video stream for `0x000001B8` and
  compared entry for entry against what the file actually stores, which
  matched exactly.
seq:
  - id: magic
    contents: 'DPG'
  - id: version_ascii
    type: u1
    doc: ASCII `'0'`-`'4'`; see `version` for the numeric form.
  - id: num_frames
    type: u4
  - id: fps_raw
    type: u4
    doc: |
      DPG0/DPG1: a whole frames-per-second value, 0 meaning 15. DPG2+: an
      8.8 fixed-point value (`raw / 256` fps), 0 meaning a flat 15 fps --
      the scaling is not written down anywhere outside the encoders in
      circulation, confirmed here by generating a 25 fps DPG2 file and
      finding `fps_raw / 256 == 25` exactly.
  - id: sample_rate
    type: u4
    doc: 0 when the file has no audio.
  - id: num_channels
    type: u4
    doc: 0 when the file has no audio; otherwise 1 or 2.
  - id: ofs_audio
    type: u4
  - id: len_audio
    type: u4
  - id: ofs_video
    type: u4
  - id: len_video
    type: u4
  - id: v2_fields
    type: v2_fields
    if: version >= 2
  - id: thumbnail_marker
    contents: 'THM0'
    if: version >= 4
  - id: thumbnail
    size: 256 * 192 * 2
    if: version >= 4
    doc: |
      256x192 16-bit pixels, the DS screen, as raw values with no image
      header -- MoonShell's file-picker thumbnail. All zero (a black
      thumbnail) when the muxer wasn't given one to embed, since leaving
      the region out entirely would move every later offset.
instances:
  version:
    value: version_ascii - 0x30
  audio:
    pos: ofs_audio
    size: len_audio
    if: len_audio > 0
    doc: Raw MP2 elementary stream bytes -- no packet boundaries of its own.
  video:
    pos: ofs_video
    size: len_video
    doc: Raw MPEG-1 elementary stream bytes -- no packet boundaries of its own.
  gop_index:
    pos: v2_fields.ofs_gop_index
    size: v2_fields.len_gop_index
    if: version >= 2 and v2_fields.len_gop_index > 0
    doc: |
      A flat array of 4-byte little-endian offsets (divide `len_gop_index`
      by 4 for the count), each one relative to `video`'s own start, not
      to the file. Exposed as raw bytes rather than a repeated `u4` array
      since a non-seekable encode leaves `len_gop_index` at 0 with the
      video otherwise complete -- the field genuinely means "no index",
      not "index of length 0" as a decoder-side default.
types:
  v2_fields:
    seq:
      - id: ofs_gop_index
        type: u4
      - id: len_gop_index
        type: u4
        doc: |
          In bytes, not entries. 0 when the output wasn't seekable at mux
          time -- the file still plays, MoonShell just cannot seek in it.
      - id: pixel_format
        type: u4
        doc: |
          MoonShell's pixel format field. 3 (24-bit) is what every current
          encoder writes; 0-2 are older 15/18/21-bit modes, unconfirmed
          against any real file here.
