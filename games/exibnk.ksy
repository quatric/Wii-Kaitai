meta:
  id: exibnk
  title: Exient sound bank (.bnk)
  file-extension: bnk
  endian: be
doc: |
  Exient sound bank (Need for Speed: Hot Pursuit, Wii). The entry list ends in
  0xFFFFFFFF words; every member is a complete `WIIADPCM` stream.
seq:
  - id: count
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: offset
        type: u4
      - id: len_data
        type: u4
      - id: zero
        type: u4
    instances:
      data:
        pos: offset
        io: _root._io
        size: len_data
