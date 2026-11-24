meta:
  id: glacier_prm
  title: IO Interactive Glacier model container (.prm)
  file-extension: prm
  endian: be
doc: |
  Mini Ninjas. Header {u32 table offset, u32 chunk count, u32 table offset, 0};
  the table at the end holds {u32 offset, u32 size, u32, 0} per chunk (chunk 0 is
  the header). Mesh descriptors are 16 bytes {u32 vertex count, u32 vertex buffer
  chunk, u16 material, u16 flags, u32 index buffer chunk}. Index buffer {u16 1,
  u16 count, count x u16}; vertices 20 bytes {f32 x, y, z, u8 0, s8 normal x,y,z
  (/127), s16 u, v (/512)} (flags 0 buffers carry 2 more bytes per vertex after
  the array).
seq:
  - id: table_offset
    type: u4
  - id: chunk_count
    type: u4
  - id: table_offset2
    type: u4
  - id: zero
    type: u4
instances:
  table:
    pos: table_offset
    type: entry
    repeat: expr
    repeat-expr: chunk_count
types:
  entry:
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: unk
        type: u4
      - id: zero
        type: u4
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
  mesh_descriptor:
    seq:
      - id: vertex_count
        type: u4
      - id: vertex_buffer_chunk
        type: u4
      - id: material
        type: u2
      - id: flags
        type: u2
      - id: index_buffer_chunk
        type: u4
  index_buffer:
    seq:
      - id: one
        type: u2
      - id: count
        type: u2
      - id: indices
        type: u2
        repeat: expr
        repeat-expr: count
  vertex:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
      - id: zero
        type: u1
      - id: normal
        type: s1
        repeat: expr
        repeat-expr: 3
      - id: u
        type: s2
      - id: v
        type: s2
