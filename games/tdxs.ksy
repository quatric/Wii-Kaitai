meta:
  id: tdxs
  title: TDXS typed table (Shawn Johnson Gymnastics)
  file-extension: bin
  endian: be
doc: |
  Rows are equal-sized runs of 32-bit words (ints, floats, name hashes);
  column types are not stored. Row size = (table_name_offset - 1 - 0x20) / row_count.
seq:
  - id: magic
    contents: TDXS
  - id: version
    type: u2
  - id: zero
    type: u2
  - id: header_size
    type: u4
    doc: 0x18.
  - id: module_name_offset
    type: u4
  - id: table_name_offset
    type: u4
  - id: unk
    type: u4
    doc: 0x00010000.
  - id: row_count
    type: u4
  - id: data_offset
    type: u4
    doc: 0x20.
instances:
  row_size:
    value: '(table_name_offset - 1 - data_offset) / row_count'
  rows:
    pos: data_offset
    size: row_size
    repeat: expr
    repeat-expr: row_count
  module_name:
    pos: module_name_offset
    type: strz
    encoding: ASCII
  table_name:
    pos: table_name_offset
    type: strz
    encoding: ASCII
