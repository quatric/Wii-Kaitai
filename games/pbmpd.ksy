meta:
  id: pbmpd
  title: Phantom Brave battle map data (mp*.mpd)
  file-extension: mpd
  endian: be
doc: |
  0x40-byte header {u16 count A @0, u16 count B @4, 16 bytes @8, ..., u32 byte
  size of the trailing u16 table @0x30}, a 64x64 grid of 4-byte cells (stored
  column by column), A records of 0x40 bytes, B records of 0x24 bytes, the u16
  table, up to 4 KiB of further data. Field meanings are not decoded.
seq:
  - id: count_a
    type: u2
  - id: unk2
    size: 2
  - id: count_b
    type: u2
  - id: unk6
    size: 2
  - id: unk8
    size: 16
  - id: unk18
    size: 0x30 - 0x18
  - id: u16_table_size
    type: u4
  - id: unk34
    size: 0x40 - 0x34
  - id: grid
    size: 4
    repeat: expr
    repeat-expr: 64 * 64
  - id: records_a
    size: 0x40
    repeat: expr
    repeat-expr: count_a
  - id: records_b
    size: 0x24
    repeat: expr
    repeat-expr: count_b
  - id: u16_table
    size: u16_table_size
  - id: tail
    size-eos: true
