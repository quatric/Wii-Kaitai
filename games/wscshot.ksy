meta:
  id: wscshot
  title: WSC Real 09 broken-shot scenario
  file-extension: dat
  endian: le
doc: Exactly 2070 bytes. The first 16 records are ball positions {x, y, 1.125 radius, 0}; the rest is not understood.
seq:
  - id: name
    size: 0x20
    type: strz
    encoding: ASCII
  - id: words
    type: u2
    repeat: expr
    repeat-expr: 3
  - id: records
    type: record
    repeat: expr
    repeat-expr: 127
types:
  record:
    seq:
      - id: a
        type: u4
      - id: b
        type: u4
      - id: c
        type: u4
      - id: d
        type: u4
