meta:
  id: gmf2
  title: Grasshopper Manufacture GMF2 model (.gm2 / .gmf2)
  file-extension: gm2
  endian: le
doc: |
  After the public "GHM File Docs" notes. Objects are 0x80 bytes {char name[8],
  flags, vertex buffer, parent, first child, prev, next, surface list, ...,
  s32 vertex divisor exponent (+0x2c), float position[3] (+0x30), scale[3]
  (+0x50)}. The vertex buffer holds big-endian s16 xyz (/ 2^exponent) or, for
  exponent -1, float xyz. Surfaces are 32 bytes. Textures are embedded GCT0.
seq:
  - id: magic
    contents: GMF2
  - id: version
    type: u4
    doc: 2.
  - id: zero
    size: 16
  - id: object_count
    type: s2
  - id: texture_count
    type: s2
  - id: unused_count
    type: s2
  - id: material_count
    type: s2
  - id: object_table_offset
    type: u4
  - id: texture_table_offset
    type: u4
  - id: unused_table_offset
    type: u4
  - id: material_table_offset
    type: u4
instances:
  objects:
    pos: object_table_offset
    type: object
    repeat: expr
    repeat-expr: object_count
types:
  object:
    seq:
      - id: name
        size: 8
        type: strz
        encoding: ASCII
      - id: flags
        type: u4
      - id: vertex_buffer
        type: u4
      - id: parent
        type: s4
      - id: first_child
        type: s4
      - id: prev
        type: s4
      - id: next
        type: s4
      - id: surface_list
        type: u4
      - id: unk28
        size: 4
      - id: divisor_exponent
        type: s4
      - id: position
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: unk3c
        size: 0x50 - 0x3c
      - id: scale
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: tail
        size: 0x80 - 0x5c
