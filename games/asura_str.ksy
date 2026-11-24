meta:
  id: asura_str
  title: Rebellion Asura engine string table (.str)
  file-extension: str
  endian: le
doc: |
  Rebellion Asura engine string table (PDC World Championship Darts, Wii). A
  count, then offsets relative to the end of the offset
  table; each string is `{u16 byte length, u16 character count, UTF-8 text,
  0xFF padding to 4 bytes}`.
seq:
  - id: num_strings
    type: u4
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: num_strings
types:
  string_record:
    seq:
      - id: len_bytes
        type: u2
      - id: num_chars
        type: u2
      - id: text
        type: str
        size: len_bytes
        encoding: UTF-8
