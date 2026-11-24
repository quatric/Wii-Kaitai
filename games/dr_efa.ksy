meta:
  id: dr_efa
  title: Dead Rising Wii effect archive (.efa)
  file-extension: efa
  endian: be
doc: |
  Dead Rising: Chop Till You Drop (Wii) `*.efa` effect archive. Each group at
  `P` is `{u32 count, 12 zero bytes, count 24-byte entries}`; the data follows the
  entry list (0x40 aligned), in order with gaps below 0x40 bytes, up to the group
  end; the next group starts there (aligned to 0x10). Only the first group is
  modelled. Members are `bres` (BRRES) or `KTPP` payloads.
seq:
  - id: magic
    contents: [0x00, 0x41, 0x46, 0x45]
  - id: first_group_offset
    type: u4
    doc: 0x40.
  - id: first_group_end
    type: u4
instances:
  first_group:
    pos: first_group_offset
    type: group
types:
  group:
    seq:
      - id: count
        type: u4
      - id: zero
        size: 12
      - id: entries
        type: entry
        repeat: expr
        repeat-expr: count
  entry:
    seq:
      - id: offset
        type: u4
      - id: len_data
        type: u4
      - id: name
        size: 16
        type: strz
        encoding: ASCII
