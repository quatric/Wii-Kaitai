meta:
  id: tdw
  title: Super Fruit Fall texture set
  file-extension: tdw
  endian: be
seq:
  - id: count
    type: u4
  - id: textures
    type: tex
    repeat: expr
    repeat-expr: count
types:
  tex:
    seq:
      - id: name
        size: 0x40
        type: strz
        encoding: ASCII
      - id: format
        type: u4
        doc: GX format, 4 RGB565, 5 RGB5A3, 6 RGBA8, 14 CMPR.
      - id: three
        type: u4
      - id: zero
        type: u4
      - id: width
        type: u4
      - id: height
        type: u4
      - id: data_size
        type: u4
      - id: data
        size: data_size
      - id: pad
        size: 4
