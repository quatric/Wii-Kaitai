meta:
  id: adev
  title: ADEV adventure event table
  file-extension: bin
  endian: be
doc: |
  `ADEV` adventure event tables (Soul Eater: Monotone Princess, Wii
  `event/AdvEvent*.bin`, `AdvRandomEvent*.bin`). Every event is 40 records of
  0x40 bytes (32 u16 words, 0xFFFF = unused); the word meanings are unknown.
seq:
  - id: magic
    contents: ADEV
  - id: len_header
    type: u4
    doc: 16 + 8 * group count.
  - id: total_events_x8
    type: u4
    doc: 8 * total event count.
  - id: num_groups
    type: u4
  - id: first_event_index
    type: u4
    repeat: expr
    repeat-expr: num_groups
  - id: num_events_in_group
    type: u4
    repeat: expr
    repeat-expr: num_groups
