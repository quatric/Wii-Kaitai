meta:
  id: midway_pha
  title: Midway animation pack (.pha)
  file-extension: pha
  endian: be
doc: |
  Midway animation pack (members of TNA Impact! `.WAD` packs). Names start at
  0x20 (NUL separated); the last name is a `ZZ_DUMMY` placeholder. Animation k's
  payload is the range up to the next record's offset. A payload is a list of
  chunks `{u16 tag, u16 a, u16 count, u16 size, ...}`: tag 0x0800 is the rotation
  of one bone (u32 bone id, then `count` words of 10-10-10-2 bits: the three
  smaller quaternion components as offset-binary values scaled by 1/sqrt(2), the
  two low bits giving the index of the dropped largest component); size = 4 *
  count + 12. Tags 0x0200/0x0280 hold a u32 id and 8-byte entries of 4 x s16.
seq:
  - id: reserved0
    size: 8
  - id: num_animations
    type: u2
  - id: reserved1
    size: 2
  - id: name_table_end
    type: u4
instances:
  records:
    pos: name_table_end
    type: record
    repeat: expr
    repeat-expr: num_animations
types:
  record:
    seq:
      - id: start_frame
        type: u4
        doc: Cumulative.
      - id: flags
        type: u4
        doc: 0x40000028.
      - id: zero0
        type: u4
      - id: speed
        type: f4
      - id: blend_time
        type: f4
      - id: zeros
        size: 12
      - id: data_offset
        type: u4
