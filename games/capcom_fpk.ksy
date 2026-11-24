meta:
  id: capcom_fpk
  title: Capcom @FPK archive (.fpk)
  file-extension: fpk
  endian: be
doc: |
  Capcom `@FPK` archive (Dead Rising: Chop Till You Drop, Wii). A member runs to
  the next larger offset (or the end of the file).
seq:
  - id: magic
    contents: '@FPK'
  - id: ffff
    type: u4
    doc: 0xFFFF.
  - id: num_groups
    type: u4
  - id: zero
    type: u4
  - id: groups
    type: group
    repeat: expr
    repeat-expr: num_groups
types:
  group:
    seq:
      - id: id
        type: u4
      - id: count
        type: u4
      - id: table_offset
        type: u4
      - id: zero
        type: u4
    instances:
      records:
        pos: table_offset
        io: _root._io
        type: record
        repeat: expr
        repeat-expr: count
  record:
    seq:
      - id: index
        type: u4
      - id: offset
        type: u4
      - id: minus_one0
        type: s4
      - id: minus_one1
        type: s4
