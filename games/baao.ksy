meta:
  id: baao
  title: BAAO attack attribute table
  file-extension: bin
  endian: be
doc: |
  `BAAO` attack attribute tables (One Piece Unlimited Adventure / Cruise, Wii
  `battle/*atk_attr*.bin`). Per group, `n` u32 ids at `ids_offset` and `n` u32
  offsets at `records_offset`.
seq:
  - id: magic
    contents: BAAO
  - id: num_groups
    type: u4
  - id: version
    type: u4
  - id: groups
    type: group
    repeat: expr
    repeat-expr: num_groups
types:
  group:
    seq:
      - id: n
        type: u4
      - id: ids_offset
        type: u4
      - id: records_offset
        type: u4
    instances:
      ids:
        pos: ids_offset
        io: _root._io
        type: u4
        repeat: expr
        repeat-expr: n
      record_offsets:
        pos: records_offset
        io: _root._io
        type: u4
        repeat: expr
        repeat-expr: n
