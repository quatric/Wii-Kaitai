meta:
  id: fbnd
  title: FBND bundle (Sega Bass Fishing, Wii)
  endian: be
doc: |
  "FBND", u32 0x630, then a zeroed file table in retail dumps; members at
  0x800-aligned offsets starting at 0x800: U8 archives ("U\xaa8-") and "BCV0"
  resources (BCV0/STRS/KIND/CROW/EOCK name index + raw payload).
seq:
  - id: magic
    contents: FBND
  - id: table_size
    type: u4
    doc: 0x630.
  - id: file_table
    size: 0x800 - 8
  - id: members
    size-eos: true
