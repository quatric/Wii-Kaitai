meta:
  id: rvid
  file-extension: rvid
  endian: le
  title: RocketVideo (Nintendo DS)
doc: |
  A DS video format (`.rvid`) with a from-scratch encoder and decoder in
  mobipeg -- see its README for the codec itself. The container is the
  simplest of the ones covered in this batch: a fixed 32-byte header, a
  flat table of absolute frame offsets at a fixed position, and (for
  compressed builds) a matching table of per-frame payload sizes -- no
  chained or lagged size fields like `media/thp.ksy`, no nested groups
  like `media/hvqm4.ksy`.

  Frame geometry is not stored directly. Width comes from the `dual`
  field (240 if it's 2, 256 otherwise) and height from `vres`, doubled
  when `is_interlaced` is set -- a convention specific to this format's
  handful of fixed DS screen-buffer shapes, not a general-purpose
  width/height pair.

  A frame's payload size is computed, not stored per frame, unless
  `ofs_compressed_sizes` is non-zero: uncompressed, every frame is exactly
  `width * vres` bytes (`bmp_mode` 0, palette-indexed, plus a fixed
  0x200-byte palette prepended) or `width * vres * 2` bytes (`bmp_mode`
  nonzero, direct RGB565) -- `vres`, not the doubled `height`, even when
  `is_interlaced` is set: an interlaced stream stores one field's worth of
  rows per frame table entry, not a full display frame, confirmed against
  the real byte gap between consecutive frame-table entries in the
  interlaced sample below. Compressed, the per-frame size comes from the
  table at `ofs_compressed_sizes` instead, still with the same 0x200-byte
  palette prefix when `bmp_mode` is 0.

  Audio, when present, is two raw PCM blobs (left channel, then right)
  rather than one interleaved stream -- `snd_right` at 0 means mono, and
  the demuxer interleaves the two blobs into stereo samples on the fly
  when reading, which this definition exposes as `audio_left`/
  `audio_right` rather than replicating that interleaving.

  ## Validated against

  No retail RVID sample was available on this machine at the time of
  writing -- Rocket Video is not one of the DS's more common formats, and
  this batch's other definitions all had a real disc or channel dump to
  check against; this one does not. In its place: two files mobipeg's own
  encoder produced (`rvid_ds_high_unlimited.rvid`, DS screen-buffer 256x144
  RGB565, and `rvid_ds_256_rgb565.rvid`, 256x144 palette-indexed), checked
  field for field against a byte-level dump -- including that the
  frame-size formula above reproduces the real gap between two consecutive
  frame-table entries exactly in both: 37376 bytes (0x200 palette +
  256*144) in the non-interlaced palette-indexed file, and 36864 bytes
  (256*72*2, `vres` not `height`) in the interlaced RGB565 one -- the
  detail that caught an initial mistake in this definition (using `height`
  instead of `vres`) before the fix below. That confirms the container's
  own arithmetic, not that these particular files represent everything a
  real RVID stream can contain -- an unusually
  literal instance of the "not yet checked against a real sample" caveat
  this project's README already flags for other formats.
seq:
  - id: magic
    contents: 'RVID'
  - id: version
    type: u4
    doc: 5 in every observed file; mobipeg's demuxer rejects anything else.
  - id: num_frames
    type: u4
  - id: fps_base
    type: u1
    doc: |
      0 means a fixed 59.8261 fps. Otherwise, the high bit set means
      `(fps_base & 0x7F) * 10 - 1` tenths of a frame per second (so 188
      means `(188 & 0x7F) * 10 - 1 = 599`, i.e. 59.9 fps); clear, it is
      simply `fps_base` whole frames per second.
  - id: vres
    type: u1
    doc: Vertical resolution -- doubled for `height` when `is_interlaced` is set.
  - id: is_interlaced
    type: u1
  - id: dual
    type: u1
    doc: |
      Selects `width`: 240 when this is 2, 256 otherwise. Values above 2
      are rejected by mobipeg's demuxer.
  - id: sample_rate
    type: u2
  - id: is_16_bit_audio
    type: u1
  - id: bmp_mode
    type: u1
    doc: |
      0 selects palette-indexed frames (a 0x200-byte palette precedes each
      frame's pixel data, and the compressed-size table, if present,
      stores 16-bit sizes); nonzero selects direct RGB565 (no palette, and
      32-bit compressed sizes).
  - id: ofs_compressed_sizes
    type: u4
    doc: 0 means every frame is the fixed uncompressed size computed from `bmp_mode`.
  - id: snd_left
    type: u4
    doc: Absolute file offset of the left (or mono) audio blob. 0 means no audio.
  - id: snd_right
    type: u4
    doc: Absolute file offset of the right audio blob. 0 means mono.
instances:
  width:
    value: 'dual == 2 ? 240 : 256'
  height:
    value: 'is_interlaced != 0 ? vres * 2 : vres'
    doc: Display height. Not what a frame's stored payload spans -- see `vres`.
  is_compressed:
    value: ofs_compressed_sizes != 0
  compressed_sizes:
    pos: ofs_compressed_sizes
    type:
      switch-on: bmp_mode
      cases:
        0: u2
        _: u4
    repeat: expr
    repeat-expr: num_frames
    if: is_compressed
  frame_table:
    pos: 0x200
    type: frame_ref(_index)
    repeat: expr
    repeat-expr: num_frames
    doc: |
      One entry per frame, in display order. Each entry resolves its own
      `payload` rather than this array exposing a flat offset list,
      because the payload's size depends on whether the file is
      compressed and (uncompressed) on `bmp_mode` -- see `frame_ref`.
  channels:
    value: 'snd_right != 0 ? 2 : 1'
  audio_left:
    pos: snd_left
    size: 'snd_right != 0 ? snd_right - snd_left : _io.size - snd_left'
    if: snd_left != 0
    doc: |
      Runs to `snd_right` when stereo, otherwise to end of file -- mono
      and stereo share this one field for where the audio region starts.
  audio_right:
    pos: snd_right
    size-eos: true
    if: snd_right != 0
types:
  frame_ref:
    params:
      - id: index
        type: u4
    seq:
      - id: ofs
        type: u4
    instances:
      len_payload:
        value: >-
          (_root.bmp_mode == 0 ? 0x200 : 0) +
          (_root.is_compressed
            ? _root.compressed_sizes[index]
            : _root.width * _root.vres * (_root.bmp_mode == 0 ? 1 : 2))
      payload:
        pos: ofs
        size: len_payload
        doc: |
          The 0x200-byte palette (when `bmp_mode` is 0) followed by the
          frame's own pixel data -- both are opaque bytes here, since
          decoding either belongs to the codec, not this container
          definition.
