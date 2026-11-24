meta:
  id: tdns
  title: TDNS sound-name table (Super Monkey Ball Step & Roll)
  file-extension: bin
  endian: be
seq:
  - id: magic
    contents: TDNS
  - id: version
    type: u4
  - id: unk8
    size: 8
  - id: count
    type: u4
  - id: pairs
    type: pair
    repeat: expr
    repeat-expr: count
types:
  pair:
    seq:
      - id: id
        type: u4
      - id: string_offset
        type: u4
    instances:
      name:
        pos: string_offset
        type: strz
        encoding: ASCII
        io: _root._io
