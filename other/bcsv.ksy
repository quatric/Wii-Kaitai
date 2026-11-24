meta:
  id: bcsv
  title: JSystem BCSV table
  file-extension: bcsv
  endian: be
doc: |
  JSystem `BCSV` table (Super Mario Galaxy 1/2, Twilight Princess, Pikmin 2 era
  games). Big endian on GameCube/Wii, little endian in Switch ports (this
  definition is the big-endian one). Field types: 0 s32, 1 char[32], 2 f32,
  3 u32, 4 s16, 5 s8, 6 u32 offset into the string pool that follows the
  entries. A value is `(raw & mask) >> shift`. Field names are stored only as
  hashes (`h = h * 31 + c`).
seq:
  - id: num_entries
    type: u4
  - id: num_fields
    type: u4
  - id: data_offset
    type: u4
  - id: entry_size
    type: u4
  - id: fields
    type: field
    repeat: expr
    repeat-expr: num_fields
instances:
  entries:
    pos: data_offset
    size: entry_size
    repeat: expr
    repeat-expr: num_entries
types:
  field:
    seq:
      - id: name_hash
        type: u4
      - id: mask
        type: u4
      - id: offset
        type: u2
      - id: shift
        type: u1
      - id: type
        type: u1
        enum: field_type
enums:
  field_type:
    0: s32
    1: char32
    2: f32
    3: u32
    4: s16
    5: s8
    6: string_offset
