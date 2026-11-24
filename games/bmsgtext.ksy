meta:
  id: bmsgtext
  title: Necro-Nesia .bmsg message table
  file-extension: bmsg
  endian: le
seq:
  - id: one
    type: u4
  - id: string_section_offset
    type: u4
  - id: zero
    type: u4
  - id: pair_count
    type: u4
  - id: pairs
    type: pair
    repeat: expr
    repeat-expr: pair_count
instances:
  strings:
    pos: string_section_offset
    type: string_section
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
  string_section:
    seq:
      - id: one
        type: u4
      - id: count
        type: u4
      - id: offsets
        type: u4
        repeat: expr
        repeat-expr: count
        doc: Relative to the section start; NUL-terminated UTF-16LE strings follow.
