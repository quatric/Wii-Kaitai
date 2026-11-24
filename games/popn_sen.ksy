meta:
  id: popn_sen
  title: pop'n music sentence table (.sen)
  file-extension: sen
  endian: be
doc: |
  pop'n music (Wii) `.sen` sentence table. The first offset equals the end of the
  table; strings are NUL-terminated UTF-16BE.
seq:
  - id: magic
    contents: ['SEN', 0]
  - id: num_strings
    type: u4
  - id: len_file
    type: u4
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: num_strings
