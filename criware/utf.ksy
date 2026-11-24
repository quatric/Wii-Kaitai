meta:
  id: utf
  title: CRI @UTF table
  endian: be
doc: |
  Used by AAX, CSB (Atom cue sheet), ACB, CPK. Column schema entries are {u8
  flags (storage = flags & 0xf0: 0x10 zero, 0x30 constant, 0x50 per row; type =
  flags & 0x0f: 0 u8, 1 s8, 2 u16, 3 s16, 4 u32, 5 s32, 6 u64, 7 s64, 8 f32, 9
  f64, 0xa string offset, 0xb data {offset, size}), u32 name offset (into the
  string pool), optional constant value}. Rows are `row_width` bytes at
  `rows_offset`; offsets are relative to byte 8 (after magic and size).
seq:
  - id: magic
    contents: "@UTF"
  - id: table_size
    type: u4
  - id: body
    size: table_size
    type: body
types:
  body:
    seq:
      - id: unk
        type: u1
      - id: encoding
        type: u1
      - id: rows_offset
        type: u2
      - id: strings_offset
        type: u4
      - id: data_offset
        type: u4
      - id: table_name_offset
        type: u4
      - id: column_count
        type: u2
      - id: row_width
        type: u2
      - id: row_count
        type: u4
      - id: columns
        type: column
        repeat: expr
        repeat-expr: column_count
  column:
    seq:
      - id: flags
        type: u1
      - id: name_offset
        type: u4
      - id: constant
        type: value(flags & 0x0f)
        if: (flags & 0xf0) == 0x30
    instances:
      storage:
        value: flags & 0xf0
      type:
        value: flags & 0x0f
  value:
    params:
      - id: kind
        type: u1
    seq:
      - id: v
        type:
          switch-on: kind
          cases:
            0: u1
            1: s1
            2: u2
            3: s2
            4: u4
            5: s4
            6: u8
            7: s8
            8: f4
            9: f8
            10: u4
            11: data_ref
  data_ref:
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
