meta:
  id: mbb_tbl
  title: Wii Chess TBB2 message table (.mbb)
  file-extension: mbb
  endian: be
doc: |
  Wii Chess (Europe) `MsgTbl/Mes<LANG>.mbb`, a `TBB2` container. Only the
  `MTBL` section at 0x20 is decoded by nintoolbox: `{"MTBL", u32 0x10,
  u32 section size, u32 string count, count u32 offsets relative to 0x30
  (0 = no string)}`, followed by NUL-terminated UTF-16BE strings.
seq:
  - id: magic
    contents: TBB2
  - id: header_size
    type: u4
    doc: 0x10.
  - id: num_sections
    type: u4
  - id: len_total
    type: u4
  - id: first_section_offset
    type: u4
    doc: 0x20.
  - id: reserved
    size: 12
  - id: mtbl
    type: mtbl
types:
  mtbl:
    seq:
      - id: magic
        contents: MTBL
      - id: header_size
        type: u4
        doc: 0x10.
      - id: len_section
        type: u4
      - id: num_strings
        type: u4
      - id: offsets
        type: u4
        repeat: expr
        repeat-expr: num_strings
        doc: Relative to 0x30; 0 = no string.
