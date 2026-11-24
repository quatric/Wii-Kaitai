meta:
  id: momotex
  title: Momotarou Dentetsu 16 TA texture
  endian: be
doc: |
  Textures back to back (each padded to 0x20), each {"TA", u16 1, u32 size,
  u32 format (4 C4, 5 C8), u32 width, height, mip count, 2 zero words, RGB5A3
  palette (16 or 256 entries), GX tiled indices (8x8 tiles C4, 8x4 C8),
  trailer}.
seq:
  - id: textures
    type: texture
    repeat: eos
types:
  texture:
    seq:
      - id: magic
        contents: TA
      - id: one
        type: u2
      - id: size
        type: u4
      - id: format
        type: u4
      - id: width
        type: u4
      - id: height
        type: u4
      - id: mip_count
        type: u4
      - id: zero
        type: u4
        repeat: expr
        repeat-expr: 2
      - id: palette
        type: u2
        repeat: expr
        repeat-expr: '(format == 4 ? 16 : 256)'
      - id: indices
        size: '(format == 4 ? width * height / 2 : width * height)'
