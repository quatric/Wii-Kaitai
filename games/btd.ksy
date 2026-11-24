meta:
  id: btd
  title: Bj engine track data (.btd, Maximum Racing)
  file-extension: btd
  endian: le
doc: |
  Little-endian PC layout. u32 magic 0xb060ffed, u32 section mask (0x7ff = 11
  sections), then 11 entries {u32 offset, u32 count, u32 -1} from +8. Section 3
  is one structure: +8 = points per line n, +0x5c + 8*i = {u32 offset of 0x20-byte
  point records, u32 offset of 12-byte records} for i < 19 lines; a point is
  {float x, y, z, 5 floats direction/side}.
seq:
  - id: magic
    type: u4
    doc: 0xb060ffed.
  - id: section_mask
    type: u4
  - id: sections
    type: section
    repeat: expr
    repeat-expr: 11
types:
  section:
    seq:
      - id: offset
        type: u4
      - id: count
        type: u4
      - id: minus_one
        type: s4
  point:
    seq:
      - id: position
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: direction_side
        type: f4
        repeat: expr
        repeat-expr: 5
