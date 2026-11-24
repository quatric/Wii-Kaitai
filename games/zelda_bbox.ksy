meta:
  id: zelda_bbox
  title: Switch 2 Zelda culling boxes (.bbox)
  file-extension: bbox
  endian: le
doc: Low mantissa bits of the center floats carry noise; positions snap to 0.5.
seq:
  - id: version
    type: u4
    doc: 2.
  - id: count
    type: u4
  - id: boxes
    type: box
    repeat: expr
    repeat-expr: count
types:
  box:
    seq:
      - id: id
        type: u4
      - id: flags
        type: u4
      - id: center
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: reserved
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: size
        type: f4
        repeat: expr
        repeat-expr: 3
