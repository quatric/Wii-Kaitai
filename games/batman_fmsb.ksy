meta:
  id: batman_fmsb
  title: Batman Brave and the Bold level object table (.fmsb)
  file-extension: fmsb
  endian: be
doc: |
  0x80-byte spatial header, then {u32 object count N at +0x90, u32 offset of the
  record offset table at +0x94 (0xe0)}. Records are 0xa0 bytes plus optional
  property words up to the next record.
seq:
  - id: spatial_header
    size: 0x90
  - id: object_count
    type: u4
  - id: table_offset
    type: u4
instances:
  offsets:
    pos: table_offset
    type: u4
    repeat: expr
    repeat-expr: object_count
types:
  object:
    seq:
      - id: bounding_radius
        type: f4
      - id: zero
        type: u4
      - id: minus_one
        type: s4
      - id: id
        type: u4
      - id: argument
        type: u4
      - id: unk14
        size: 0x2c - 0x14
      - id: position
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: scale
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: unk44_model
        size: 0xa0 - 0x44
        doc: Model name (NUL-terminated) at +0x44.
