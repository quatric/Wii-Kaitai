meta:
  id: ea_gfn
  title: EA FntG bitmap font (.gfn)
  file-extension: gfn
  endian: be
doc: |
  Big endian except the little-endian file size at +4. @0x0a u16 glyph count,
  @0x14 glyph table offset (0x80), @0x30 image header offset. Image header:
  {.., data size @+0x0c, width @+0x18, height @+0x1c}; GX I4 (8x8 tiles) atlas
  at +0x30.
seq:
  - id: magic
    size: 4
  - id: file_size
    type: u4le
  - id: unk8
    size: 2
  - id: glyph_count
    type: u2
  - id: unk0c
    size: 8
  - id: glyph_table_offset
    type: u4
  - id: unk18
    size: 0x30 - 0x18
  - id: image_header_offset
    type: u4
instances:
  glyphs:
    pos: glyph_table_offset
    type: glyph
    repeat: expr
    repeat-expr: glyph_count
types:
  glyph:
    seq:
      - id: char
        type: u2
      - id: w
        type: u1
      - id: h
        type: u1
      - id: x
        type: u2
      - id: y
        type: u2
      - id: unk
        type: u2
      - id: xoff
        type: s1
      - id: yoff
        type: s1
      - id: unk2
        type: u2
      - id: advance
        type: u2
