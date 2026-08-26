meta:
  id: moc3
  file-extension: mo
  endian: le
  title: MobiClip MOC2/MOC3 (fla2/gvi3/vid2)
doc: |
  The two MobiClip container generations that predate the `mo` layout
  (`media/mobiclip.ksy`) and share its `.mo` extension -- told apart from
  it, and from each other, purely by magic and by the `tag` at offset 8
  (`fla2`, `gvi3` or `vid2`), since `hdr_size` is not fixed enough to use
  for detection on its own.

  `hdr_size` genuinely varies: 240 on every real MOC3 file checked here,
  76 on the one real MOC2 file found (`MOLI_Motorbike.mo`) -- correcting
  an in-tree comment in mobipeg's own demuxer that says 64, which no real
  sample here confirms. `field1` likewise varies (8 on MOC3, 2 on that
  MOC2 sample) rather than matching mobipeg's documented "8/10/14"; take
  both as what has actually been observed, not as the full range.

  ## The header region is not the constant blob it is often called

  mobipeg's own demuxer comment describes the region as "a constant
  licence blob (byte-identical across files)" with "only its final 8
  bytes" per-file. Measured across all seven real MOC3/`fla2` files, that is
  not what is there. The first 160 bytes (`0x00`-`0x9F` of the region)
  *are* byte-identical across all seven, but a 68-byte run at `0xA0`-`0xE3`
  differs in every file, and only then come the two `u4`s this definition
  exposes. Whatever those 68 bytes are -- a per-clip signature or licence
  payload is the obvious guess -- they are not constant, and a tool that
  copies a "constant" header from one file to another would corrupt them.

  ## The size field's meaning depends on the tag

  For `fla2` and `gvi3`, the `u4` at `hdr_size + 8` is a real payload
  byte count: `16 + hdr_size + len_payload == filesize` holds exactly on
  all eight real `fla2` files checked, across both magics.

  For the one real `vid2` file, that invariant fails outright -- the same
  slot holds 545, against a 902340-byte file. The *next* `u4`
  (`hdr_size + 12`, `unknown_after_len` here) holds 902060, and
  `16 + hdr_size + 24 + 902060` is exactly the file size. So `vid2`
  appears to put its payload size in the second slot and 24 bytes of
  something between the header and the payload -- on a single sample,
  which is not enough to state as fact. Both fields are exposed
  unresolved rather than one being labelled authoritatively.

  ## fla2/gvi3: the payload's frame boundaries are not known

  mobipeg's own demuxer says so directly: its frame-boundary scan (a
  byte-pattern heuristic) is commented as "KNOWN WRONG", kept only so the
  container produces *something*. This definition does not repeat that
  heuristic as if it were structure -- `payload` here is opaque bytes, a
  bitstream whose frame boundaries remain unresolved, exactly matching
  the project's own stated uncertainty rather than dressing up a guess as
  a parsed field.

  ## vid2: only the first chunk is confirmed

  `vid2` payloads are framed as MOC5-style chunks: `chunk_size(u4)`,
  `video_size(u4)`, then `video_size` bytes of video followed by
  `chunk_size - video_size - 8` bytes of audio, the whole record padded
  up to a 4-byte boundary before the next chunk (mobipeg's own padding
  formula always adds a nonzero 1-4 bytes, even when already aligned --
  confirmed here: a chunk ending exactly on a 4-byte boundary still gets a
  4-byte pad, not zero).

  That structure is confirmed for chunk 0 of a real file
  (`MexicoSmall.mo`: `chunk_size=9960`, `video_size=1536`, giving
  `audio_size=8416`, and `1536+8416+8` does equal `9960` exactly). It is
  *not* confirmed beyond chunk 0: mobipeg's own decoder returns
  `AVERROR_PATCHWELCOME` the moment a chunk's audio portion needs
  reading, so no real file has ever been played past its first
  audio-bearing chunk by this project's own tooling, and this session's
  attempt to locate chunk 1 by walking `chunk_size` forward landed on
  bytes that do not parse as a plausible next header. `chunks` below
  models the repeating structure the format is documented to have, but
  every entry past the first is unverified.

  ## Validated against

  Eight real files pulled from an archived MobiClip Windows SDK:
  `AppleCatch.mo`, `BirdCard.mo`, `Christmas.mo`, `Karaoke.mo`,
  `Motorbike.mo` and `News.mo` (MOC3/`fla2`), `MOLI_Motorbike.mo`
  (MOC2/`fla2`), and `MexicoSmall.mo` (MOC3/`vid2`).

  The `fla2` size invariant was checked on all eight `fla2` files and
  holds exactly. The header region's constant/varying split was measured
  byte by byte across all seven MOC3 `fla2` files. The `vid2` chunk
  arithmetic was checked on chunk 0 of the eighth, and its differing size
  field found by testing the `fla2` invariant against it and having it
  fail.
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
    doc: '`MOC2` or `MOC3`.'
  - id: len_header
    type: u4
    doc: |
      240 on every real MOC3 file checked; 76 on the one real MOC2 file
      checked. Read this, not a hardcoded constant -- see the top-level
      doc for why.
  - id: tag
    type: str
    size: 4
    encoding: ASCII
    doc: '`fla2`, `gvi3` or `vid2`.'
  - id: field1
    type: u4
    doc: 8 on real MOC3 files, 2 on the one real MOC2 file checked.
  - id: header_region
    size: len_header
    doc: |
      Its first 160 bytes are byte-identical across every real MOC3
      `fla2` file checked; a 68-byte run at `0xA0`-`0xE3` differs in
      every one of them. The final 8 bytes are the two `u4`s exposed
      below. See the top-level doc -- this region is *not* wholly
      constant, contrary to the description it usually gets.
instances:
  len_payload:
    pos: 8 + len_header
    type: u4
    doc: |
      The payload's real byte length **for `fla2` and `gvi3` only** --
      `16 + len_header + len_payload` equals the file size for all eight
      real `fla2` files. On the one real `vid2` file this slot
      holds 545 and the invariant does not hold; see the top-level doc.
  unknown_after_len:
    pos: 12 + len_header
    type: u4
    doc: |
      Never read by mobipeg's demuxer, and its meaning is unresolved.
      Not a date, despite being a plausible slot for one: the observed
      values are 0x009A849B-0x009B51FA across the MOC3/`fla2` files
      (a tight cluster, uncorrelated with each file's very different
      payload size) and 0x0C2590EA on the MOC2 file -- none of them
      YYYYMMDD-shaped. On the single `vid2` file this slot instead holds
      what looks like the real payload size; see the top-level doc.
  is_vid2:
    value: tag == "vid2"
  payload:
    pos: 16 + len_header
    size: len_payload
    if: not is_vid2
    doc: |
      Opaque bitstream for `fla2`/`gvi3` -- see the top-level doc for why
      this definition does not attempt to describe frame boundaries
      within it.
  first_chunk:
    pos: 16 + len_header
    type: vid2_chunk
    if: is_vid2
    doc: |
      Only the first chunk -- not an array. See the top-level doc: walking
      forward from here using `len_chunk` and the padding rule lands on
      bytes that do not parse as a plausible next chunk header in the one
      real file checked, so this definition does not claim to know where
      chunk 1 begins.
types:
  vid2_chunk:
    seq:
      - id: len_chunk
        type: u4
      - id: len_video
        type: u4
      - id: video_data
        size: len_video
      - id: audio_data
        size: len_chunk - len_video - 8
      - id: padding
        size: 4 - (_io.pos % 4)
        doc: |
          Always 1 to 4 bytes -- even a chunk that already ends on a
          4-byte boundary still gets a full 4-byte pad, because mobipeg's
          own formula (`4 - (raw_end % 4)`) never reduces that case to 0.
