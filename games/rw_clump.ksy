meta:
  id: rw_clump
  title: Criterion RenderWare chunk stream (.rws / .dff)
  file-extension: dff
  endian: le
doc: |
  Stock little-endian chunks {u32 type, u32 size, u32 version}. Clump 0x10 ->
  GeometryList 0x1a -> Geometry 0xf whose Struct (0x01) carries flags, triangle /
  vertex / morph-target counts, optional prelit colours and UV sets, the triangle
  list {v2, v1, material, v3} and morph positions and normals (version >= 3.4).
seq:
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: type
        type: u4
      - id: size
        type: u4
      - id: version
        type: u4
      - id: body
        size: size
  geometry_struct:
    seq:
      - id: flags
        type: u4
      - id: triangle_count
        type: u4
      - id: vertex_count
        type: u4
      - id: morph_target_count
        type: u4
