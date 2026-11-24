meta:
  id: nffont
  title: Gamebryo bitmap font (.nff, Monster Mayhem)
  file-extension: nff
  endian: le
doc: |
  Header with the point size, glyph code list (u16 per glyph, first is the
  replacement glyph) and cell table ending in {u32 width, u32 height, u32 32};
  the atlas follows as width * height RGBA8 pixels.
seq:
  - id: magic
    contents: ["NFF", 0]
  - id: version
    type: u4
    doc: 1-3.
  - id: name_length
    type: u4
  - id: name
    size: name_length
    type: strz
    encoding: ASCII
  - id: rest
    size-eos: true
