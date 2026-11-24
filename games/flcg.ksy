meta:
  id: flcg
  title: Grasshopper Manufacture FLCG static collision (.GCL)
  file-extension: gcl
  endian: be
doc: |
  Grasshopper Manufacture `FLCG` static collision (No More Heroes `.GCL`, e.g.
  `STG_HI/AREA040COL.GCL`; after the public "GHM File Docs" notes). Big endian
  apart from the version word. Models are linked records (next offset at +0x1C,
  0x50 apart in practice) `{char name[8], ..., float origin[3] (+0x20), u32 data
  offset (+0x38)}`; the data record `{u32 ?, u32 triangle offset, u32 ?, u32
  triangle count, 6 floats bounding box}` points to 48-byte triangles `{u32 next,
  0, u32 material offset, float v0[3], v1[3], v2[3]}`; material records are 32
  bytes, name first.
seq:
  - id: magic
    contents: FLCG
  - id: version
    type: u4le
    doc: 1, little endian.
  - id: zero
    type: u4
  - id: num_models
    type: u2
  - id: num_materials
    type: u2
  - id: model_table_offset
    type: u4
  - id: material_table_offset
    type: u4
