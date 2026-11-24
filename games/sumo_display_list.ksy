meta:
  id: sumo_display_list
  title: GX display list used by Sumo COG meshes
  endian: be
doc: |
  Aligned to 0x20 after the attribute descriptors. Opcodes 0x80 quads, 0x90
  triangles, 0x98 strip, 0xA0 fan; u16 vertex count then one u8/u16 index per
  descriptor, in order.
params:
  - id: num_columns
    type: u4
  - id: wide_index
    type: bool
seq:
  - id: commands
    type: command
    repeat: until
    repeat-until: _.opcode == 0 or _io.eof
types:
  command:
    seq:
      - id: opcode
        type: u1
      - id: vertex_count
        type: u2
        if: opcode != 0
      - id: vertices
        type: vertex
        repeat: expr
        repeat-expr: vertex_count
        if: opcode != 0
  vertex:
    seq:
      - id: narrow
        type: u1
        repeat: expr
        repeat-expr: _root.num_columns
        if: not _root.wide_index
      - id: wide
        type: u2
        repeat: expr
        repeat-expr: _root.num_columns
        if: _root.wide_index
