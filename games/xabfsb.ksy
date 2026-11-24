meta:
  id: xabfsb
  title: Igor The Game .xab sound bank
  file-extension: xab
  endian: be
doc: |
  "chkf" chunk file (name table "xab\0header\0progdata\0wavedata\0...", then the
  parameters) with an FMOD "FSB4" bank embedded at an unaligned offset behind
  them. FSB4 size = 0x30 + sample header size + data size (little-endian fields).
seq:
  - id: magic
    contents: chkf
  - id: string_table_size
    type: u4
  - id: string_table
    size: string_table_size
  - id: rest
    size-eos: true
