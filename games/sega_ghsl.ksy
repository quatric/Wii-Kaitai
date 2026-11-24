meta:
  id: sega_ghsl
  title: SEGA GHSL hierarchical data (Sakura Wars So Long My Love)
  file-extension: bin
  endian: le
doc: |
  Flags 0x200 mean an encrypted body (gameinfo.bin). At 0x10 a u32 distance D
  to the string table at 0x10 + D ({u32 count, count x u32 offset from the
  table start}, Shift-JIS C strings); the token stream starts at 0x14. Token top
  two bits: 00 node, 01 attribute, 10 plain value, 11 end of children. Node
  byte: bits 5-4 / 3-2 / 1-0 = byte count - 1 of name index, child offset A,
  sibling offset B; attribute: bits 5-4 name size - 1, 3-2 value size - 1,
  1-0 type (0 number, 2 string index). Tokens are bit-packed with variable-width
  signed fields, so only the header and string table are modelled.
seq:
  - id: magic
    contents: GHSL
  - id: size
    type: u4
  - id: header_size
    type: u4
    doc: 0x10.
  - id: flags
    type: u4
    doc: 0x200 = encrypted body.
  - id: string_table_distance
    type: u4
  - id: tokens
    size-eos: true
instances:
  string_table:
    pos: 0x10 + string_table_distance
    type: string_table
types:
  string_table:
    seq:
      - id: count
        type: u4
      - id: offsets
        type: u4
        repeat: expr
        repeat-expr: count
