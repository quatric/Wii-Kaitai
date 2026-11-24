meta:
  id: dcf
  title: Speed 2 font cache (.dcf, "DC2")
  file-extension: dcf
  endian: be
seq:
  - id: magic
    size: 4
    doc: '"DC2\0".'
  - id: zero
    type: u4
  - id: x800
    type: u4
  - id: x100
    type: u4
  - id: x40000_a
    type: u4
  - id: atlas_words
    type: u4
    doc: Atlas bytes / 4; the atlas is GX IA4, 1024 pixels wide.
  - id: x40000_b
    type: u4
  - id: atlas
    size: atlas_words * 4
  - id: pad
    size: 3
  - id: glyphs
    type: glyph
    repeat: eos
types:
  glyph:
    seq:
      - id: code
        type: u2
      - id: x0
        type: f4
      - id: y0
        type: f4
      - id: x1
        type: f4
      - id: y1
        type: f4
      - id: advance
        type: f4
