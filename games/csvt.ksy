meta:
  id: csvt
  title: Capcom CSVT data table
  file-extension: csvtbl
  endian: be
doc: |
  Capcom `CSVT` data tables (Resident Evil Umbrella / Darkside Chronicles
  `.aitbl .atk .vop .csvtbl`). A table is `rows x columns` cells of 8 bytes
  `{u32 type, u32 value}`: 0 empty, 1 integer, 2 float, 3 string (value =
  offset of a NUL-terminated string).
seq:
  - id: magic
    contents: CSVT
  - id: version
    type: u4
  - id: num_tables
    type: u4
  - id: descriptor_offset
    type: u4
    doc: 0x10.
instances:
  descriptors:
    pos: descriptor_offset
    type: descriptor
    repeat: expr
    repeat-expr: num_tables
types:
  descriptor:
    seq:
      - id: name
        size: 0x10
        type: strz
        encoding: ASCII
      - id: num_columns
        type: u4
      - id: num_rows
        type: u4
      - id: data_offset
        type: u4
      - id: zero
        type: u4
    instances:
      cells:
        pos: data_offset
        io: _root._io
        type: cell
        repeat: expr
        repeat-expr: num_rows * num_columns
  cell:
    seq:
      - id: type
        type: u4
        enum: cell_type
      - id: value
        type: u4
enums:
  cell_type:
    0: empty
    1: integer
    2: float
    3: string
