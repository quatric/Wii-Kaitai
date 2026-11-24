meta:
  id: spectrobes_hit
  title: Spectrobes Origins collision geometry (.HIT)
  file-extension: hit
  endian: be
doc: |
  Magic 0f0f0f0f. Wall and ground groups hold 0x90-byte quad records {4 floats
  (0.5, 0.5, 0.5, 1.0), 3x4 floats {A.x, A.y, A.z, D.x}, {B.x, B.y, B.z, D.y},
  {C.x, C.y, C.z, D.z}, 5 plane rows {nx, ny, nz, w}}; other groups (0x60-byte
  object nodes of the small .HIT files) are skipped.
seq:
  - id: magic
    contents: [0x0f, 0x0f, 0x0f, 0x0f]
  - id: table_count
    type: u4
  - id: flags
    type: u4
  - id: group_data_offset
    type: u4
  - id: tables
    type: table
    repeat: expr
    repeat-expr: table_count
types:
  table:
    seq:
      - id: group_count
        type: u4
      - id: groups_offset
        type: u4
      - id: id
        type: u4
      - id: zero
        type: u4
    instances:
      groups:
        pos: groups_offset
        type: group
        repeat: expr
        repeat-expr: group_count
        io: _root._io
  group:
    seq:
      - id: name
        size: 0x20
        type: strz
        encoding: ASCII
      - id: record_count
        type: u4
      - id: first_record_offset
        type: u4
      - id: section_end
        type: u4
      - id: id
        type: u4
  quad:
    seq:
      - id: head
        type: f4
        repeat: expr
        repeat-expr: 4
      - id: corners
        type: f4
        repeat: expr
        repeat-expr: 12
      - id: planes
        type: f4
        repeat: expr
        repeat-expr: 20
