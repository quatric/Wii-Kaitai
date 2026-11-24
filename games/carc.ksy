meta:
  id: carc
  title: CARC resource pack (.carc)
  file-extension: carc
  endian: be
doc: |
  `CARC` resource pack (Haneru no Tobira Wii and relatives). NUL-terminated
  member paths (e.g. `2d/main/title.arc`) from 0x10, zero padded, then `count`
  absolute data offsets (ascending, 0x20-aligned); each member runs to the next
  offset, the last to the end of the file. Members are U8 archives, TPL, BRRES.
seq:
  - id: magic
    contents: [0x0a, 0x0b, 0x0e, 0x80]
  - id: count
    type: u4
  - id: name_table_offset
    type: u4
    doc: 0x10.
  - id: offset_table_position
    type: u4
instances:
  offsets:
    pos: offset_table_position
    type: u4
    repeat: expr
    repeat-expr: count
