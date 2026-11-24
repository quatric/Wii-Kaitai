meta:
  id: necro_bmsg
  title: Necro-Nesia message table (.bmsg)
  file-extension: bmsg
  endian: le
doc: |
  Necro-Nesia (Wii) `<LANG>/*.bmsg`. At the string section sits `{u32 1,
  u32 string count, count u32 offsets relative to the section start}` followed
  by NUL-terminated UTF-16LE strings. The label table is not decoded by
  nintoolbox.
seq:
  - id: one
    type: u4
  - id: string_section_offset
    type: u4
  - id: zero
    type: u4
  - id: num_pairs
    type: u4
  - id: pairs
    type: pair
    repeat: expr
    repeat-expr: num_pairs
instances:
  num_strings:
    pos: string_section_offset + 4
    type: u4
  string_offsets:
    pos: string_section_offset + 8
    type: u4
    repeat: expr
    repeat-expr: num_strings
    doc: Relative to the string section.
types:
  pair:
    seq:
      - id: label_index
        type: u2
      - id: string_index
        type: u2
      - id: one
        type: u2
      - id: zero
        type: u2
