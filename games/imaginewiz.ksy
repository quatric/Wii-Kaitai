meta:
  id: imaginewiz
  title: Ubisoft Imagine wiz static model
  endian: be
doc: |
  Usually LZSS wrapped. +0 u32 mesh blob size (texture table follows), +4 u32
  offset of the mesh table, +0x34.. bounding data. Mesh table: u32 count, count x
  u32 record offset (absolute). Mesh record R: +0/+4/+8/+0xc = offsets (relative
  to R) of position (float3), normal, colour (u16) and texcoord (float2) arrays,
  each preceded by its u32 byte size; +0x2c/+0x2e/+0x30 byte vertex attribute
  modes (2 = u8 index, 3 = u16 index); +0x3a u16 position count; GX display list
  (0x80 quads, 0x90 triangles, 0x98 strip, 0xa0 fan, u16 vertex count, one index
  per attribute) starts at R + 0x80. Texture table at the mesh blob end: u32
  count, u32, count x u32 entry offset; entry {u32 data offset, u16 width, u16
  height, u32 GX format (14 = CMPR)}.
seq:
  - id: mesh_blob_size
    type: u4
  - id: mesh_table_offset
    type: u4
  - id: unk8
    size: 0x34 - 8
  - id: bounding
    size: 0x40 - 0x34
instances:
  mesh_table:
    pos: mesh_table_offset
    type: mesh_table
types:
  mesh_table:
    seq:
      - id: count
        type: u4
      - id: record_offsets
        type: u4
        repeat: expr
        repeat-expr: count
  texture_table:
    seq:
      - id: count
        type: u4
      - id: unk
        type: u4
      - id: entry_offsets
        type: u4
        repeat: expr
        repeat-expr: count
  texture_entry:
    seq:
      - id: data_offset
        type: u4
      - id: width
        type: u2
      - id: height
        type: u2
      - id: gx_format
        type: u4
