meta:
  id: zelda_flnt
  title: Switch 2 Zelda foliage impostor info (.flnt)
  file-extension: flnt
  endian: le
doc: |
  Impostor info: {u32 version 2, 0, N names, R records}, N x 256-byte pascal
  strings (u8 length, bytes), N x {u32 first record, count, kind, 0} ranges, R x
  80-byte records (20 f32: impostor frame matrices). The 1168-byte node-tree
  variant is {u8 nodes (<= 32), u8 records (<= 64), u16 0x100, f32, f32}, nodes
  x 12 bytes at 0x0c, records x 12 bytes at 0x190.
seq:
  - id: version
    type: u4
  - id: zero
    type: u4
  - id: name_count
    type: u4
  - id: record_count
    type: u4
  - id: names
    type: pascal256
    repeat: expr
    repeat-expr: name_count
  - id: ranges
    type: range
    repeat: expr
    repeat-expr: name_count
  - id: records
    type: record
    repeat: expr
    repeat-expr: record_count
types:
  pascal256:
    seq:
      - id: length
        type: u1
      - id: text
        size: length
        type: str
        encoding: ASCII
      - id: pad
        size: 255 - length
  range:
    seq:
      - id: first_record
        type: u4
      - id: count
        type: u4
      - id: kind
        type: u4
      - id: zero
        type: u4
  record:
    seq:
      - id: matrix
        type: f4
        repeat: expr
        repeat-expr: 20
