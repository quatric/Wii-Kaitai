meta:
  id: smashmoi
  endian: be
  title: Super Smash Bros. 4 model index (MOI)
doc: |
  Super Smash Bros. 4 model index (.moi), per lib-smashvbn.c (ported
  from KillzXGaming/Smash-Forge MOI.cs). Each record leads with a
  name-table offset.
seq:
  - id: num_entries
    type: u4
  - id: num_other
    type: u4
  - id: entries_start
    type: u4
    doc: Always 0x30.
  - id: entry_stride
    type: u4
    doc: Always 0x20.
  - id: other_stride
    type: u4
    doc: Always 8.
  - id: unknown_14
    type: u4
    doc: Always 0x30.
  - id: other_start
    type: u4
instances:
  entries:
    type: entry_t
    repeat: expr
    repeat-expr: num_entries
    pos: entries_start
  others:
    type: other_t
    repeat: expr
    repeat-expr: num_other
    pos: other_start
types:
  entry_t:
    doc: 32-byte (8 u32) record, first word is a name-table offset.
    seq:
      - id: name_offset
        type: u4
      - id: fields
        type: u4
        repeat: expr
        repeat-expr: 7
  other_t:
    doc: 8-byte (2 u32) record, first word is a name-table offset.
    seq:
      - id: name_offset
        type: u4
      - id: value
        type: s4
