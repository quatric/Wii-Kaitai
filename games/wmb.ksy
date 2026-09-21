meta:
  id: wmb
  endian: be
  title: PlatinumGames WMB model (Star Fox Zero, Wii U)
doc: |
  PlatinumGames WMB model, per lib-wmb.c (ported from
  Kerilk/noesis_bayonetta_pc Bayo.h). Only the fixed 0x80-byte
  header's known-offset fields are modeled here; vertex/bone/
  material/mesh tables are variable-layout and format-dependent
  (a `wmb_layout_t` lookup keyed by format/mapping/unk_d) and are
  not expanded.
seq:
  - id: magic
    contents: [0x00, 0x42, 0x4d, 0x57]
  - id: unknown_04
    size: 4
  - id: format
    type: u4
  - id: num_verts
    type: u4
  - id: mapping
    type: u1
  - id: unknown_d
    type: u1
  - id: unknown_12
    size: 2
  - id: vertex_positions_offset
    type: u4
  - id: vertex_offset
    type: u4
  - id: vertex_ex_offset
    type: u4
  - id: unknown_20
    size: 0x30 - 0x20
  - id: num_bones
    type: u4
  - id: bone_hierarchy_offset
    type: u4
  - id: bone_rel_a_offset
    type: u4
  - id: bone_rel_b_offset
    type: u4
  - id: unknown_40
    size: 0x50 - 0x40
  - id: num_meshes
    type: u4
  - id: mesh_offset_table
    type: u4
  - id: mesh_base_offset
    type: u4
  - id: unknown_5c
    size: 0x80 - 0x5c
