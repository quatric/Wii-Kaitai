meta:
  id: capcom_lpk
  title: Capcom @LPK archive (.lpk)
  file-extension: lpk
  endian: be
doc: |
  Capcom `@LPK` archive (Dead Rising: Chop Till You Drop, Wii).
seq:
  - id: magic
    contents: '@LPK'
  - id: zero0
    type: u4
  - id: count
    type: u4
  - id: zero1
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: name
        size: 0x28
        type: strz
        encoding: ASCII
      - id: len_data
        type: u4
      - id: offset
        type: u4
    instances:
      data:
        pos: offset
        io: _root._io
        size: len_data
