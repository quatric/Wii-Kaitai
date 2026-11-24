meta:
  id: eurocom_filelist
  title: Eurocom EngineX Filelist.bin index
  file-extension: bin
  endian: be
doc: |
  Eurocom EngineX `Filelist.bin` index for `Filelist.000` (GoldenEye 007, Wii).
  At the name table offset + 0x10 follow `entry count + 1` self-relative u32
  pointers and as many NUL-terminated strings (the retail index has one string
  more than records). Byte j of string i is stored as `plain + j + 0xEA + i`
  (mod 256), the same start key in Filelist.bin and the File_USA/FRE/SPA
  indexes. 918 files in the retail Filelist.
seq:
  - id: seven
    type: u4
    doc: 7.
  - id: len_index
    type: u4
  - id: num_entries_plus_1
    type: u4
  - id: constant_0x10000
    type: u4
  - id: name_table_offset_minus_0x10
    type: u4
  - id: five
    type: u4
  - id: reserved
    size: 0x10
  - id: records
    type: record
    repeat: expr
    repeat-expr: num_entries_plus_1 - 1
types:
  record:
    seq:
      - id: offset
        type: u4
        doc: Into `Filelist.000`, 0x800 aligned.
      - id: zero
        type: u4
      - id: len_data
        type: u4
      - id: type_word
        type: u4
      - id: flags
        type: u4
      - id: flags2
        type: u4
      - id: one
        type: u4
