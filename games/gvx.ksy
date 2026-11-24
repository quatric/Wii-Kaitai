meta:
  id: gvx
  title: GVX0 event script (.pvx, Power Punch)
  file-extension: pvx
  endian: le
doc: |
  Tables: A = count 8-byte nodes {u32 flags, u32 index}; B = 24-byte records
  {u16 kind, u16 flags, u32 arg x5}; C = 16-byte records; D = parameter blocks
  separated by 0xfffffffe (floats, -1 words and NUL-terminated strings). The
  record semantics are not decoded.
seq:
  - id: magic
    contents: GVX0
  - id: version
    type: u4
    doc: 0x116.
  - id: flag
    type: u4
  - id: x28
    type: u4
  - id: table_a_start
    type: u4
    doc: 0x30.
  - id: table_b_start
    type: u4
  - id: table_c_start
    type: u4
  - id: table_d_start
    type: u4
  - id: file_size_a
    type: u4
  - id: file_size_b
    type: u4
  - id: node_count
    type: u4
  - id: one
    type: u4
instances:
  nodes:
    pos: table_a_start
    type: node
    repeat: expr
    repeat-expr: node_count
  records_b:
    pos: table_b_start
    type: record_b
    repeat: expr
    repeat-expr: (table_c_start - table_b_start) / 24
types:
  node:
    seq:
      - id: flags
        type: u4
      - id: index
        type: u4
  record_b:
    seq:
      - id: kind
        type: u2
      - id: flags
        type: u2
      - id: args
        type: u4
        repeat: expr
        repeat-expr: 5
