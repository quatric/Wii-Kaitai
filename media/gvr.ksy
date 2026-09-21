meta:
  id: gvr
  file-extension: gvr
  endian: be
  title: Sega GVR GameCube/Wii texture
doc: |
  Sega's GameCube/Wii texture wrapper (Super Monkey Ball: Banana Blitz and
  other Sega titles). A tiny "GCIX" index chunk is followed by a "GVRT"
  chunk whose body holds width/height/format and then the pixel data in
  the GX GameCube tile layouts (4x4 or 8x8 blocks, depending on format).
  Mipmaps and paletted formats are not covered here (the decoder in
  lib-gvr.c rejects them), and the tiled pixel data itself is left as raw
  bytes since untiling is algorithmic, not structural.
seq:
  - id: gcix_magic
    contents: "GCIX"
  - id: gcix_chunk_size
    type: u4
    doc: Size of the GCIX chunk body that follows (in bytes).
  - id: gcix_body
    size: gcix_chunk_size
    doc: Global index table; not decoded here.
  - id: gvrt_magic
    contents: "GVRT"
  - id: gvrt_chunk_size
    type: u4
    doc: Size of the GVRT chunk body that follows (header + pixel data).
  - id: reserved
    size: 2
  - id: flags
    type: u1
    doc: Low nibble carries mipmap/palette/external-palette flags.
  - id: format
    type: u1
    enum: gvr_format
  - id: width
    type: u2
  - id: height
    type: u2
  - id: pixel_data
    size-eos: true
    doc: |
      Tile-encoded pixel data in the GX layout for `format` (see
      lib-gvr.c's `DecodeGVR_RGBA` for the per-format block layout and
      untiling logic).
enums:
  gvr_format:
    0: i4
    1: i8
    2: ia4
    3: ia8
    4: rgb565
    5: rgb5a3
    6: argb8888
    0x0e: cmpr_dxt1
