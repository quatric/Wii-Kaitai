meta:
  id: igor_chkf
  title: Igor The Game Exient chkf container (.ggm / .nav / .xga)
  endian: be
doc: |
  {"chkf", u32 N} then an N-byte string table (type, section names, every name
  and matrix text; offsets below are relative to it), then header words (data
  size at +0x1c, node/key count at +0x20). .ggm ("xgm"): node records at +0x24,
  20 bytes each {u32 index, u32 parent (-1 root), u32 name offset, u32 offset of
  local 4x4 matrix text, u32 offset of inverse bind matrix text}; mesh
  descriptors {u32 palette size, vertex format name offset, vertex data offset,
  vertex count, stride 0x18, 0, primitive name offset, index count, index data
  offset, 0, ...}; vertices {f32 x,y,z, s16 nx,ny,nz (/32768), u8 skin slot or
  2 colour bytes, 0, s16 u,v (/1024)}. .nav ("nav"): data {u32 0,1,4,0, data
  size, V, T}, V records {f32 x,y,z, 16 bytes, u32 n, n x u32}, T records {3 x
  u32 vertex, 3 x s32 neighbour, 0}. .xga ("xga"): C channels {u32 0x14, 0x29,
  name offset, kind offset, key byte offset}; keys {f32 quaternion, f32
  translation, f32 scale} = 32 bytes.
seq:
  - id: magic
    contents: chkf
  - id: string_table_size
    type: u4
  - id: string_table
    size: string_table_size
  - id: body
    size-eos: true
types:
  ggm_node:
    seq:
      - id: index
        type: u4
      - id: parent
        type: s4
      - id: name_offset
        type: u4
      - id: local_matrix_offset
        type: u4
      - id: inverse_bind_offset
        type: u4
  xga_key:
    seq:
      - id: quaternion
        type: f4
        repeat: expr
        repeat-expr: 4
      - id: translation
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: scale
        type: f4
