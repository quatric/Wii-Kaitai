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
    doc: Big-endian `\0BMW` signature used by the Star Fox Zero WMB form.
  - id: unknown_04
    size: 4
    doc: Unknown header word at 0x04; preserve it.
  - id: format
    type: u4
    doc: >-
      Vertex-format key.  It combines with mapping and unknown_d to select
      one of the seven verified interleaved vertex layouts in nintoolbox.
  - id: num_verts
    type: u4
    doc: Number of interleaved vertices; nintoolbox permits 1..16 MiB.
  - id: mapping
    type: u1
    doc: Vertex-mapping count/layout selector used with format and unknown_d.
  - id: unknown_d
    type: u1
    doc: Vertex-layout selector byte; it is part of the verified layout key.
  - id: unknown_12
    size: 2
    doc: Unknown bytes at 0x12..0x13; preserve them.
  - id: vertex_positions_offset
    type: u4
    doc: Observed vertex-position-related offset at 0x14; retained unparsed.
  - id: vertex_offset
    type: u4
    doc: Absolute offset of the interleaved vertex stream.
  - id: vertex_ex_offset
    type: u4
    doc: >-
      Absolute offset of the per-vertex extension stream.  Only selected
      format/mapping combinations use it for colour and/or a second UV set.
  - id: unknown_20
    size: 0x30 - 0x20
    doc: Unknown header bytes at 0x20..0x2f.
  - id: num_bones
    type: u4
    doc: Skeleton joint count.  Non-zero requires all three bone-table offsets.
  - id: bone_hierarchy_offset
    type: u4
    doc: Absolute offset of num_bones signed 16-bit parent indexes (-1 = root).
  - id: bone_rel_a_offset
    type: u4
    doc: Absolute offset of num_bones big-endian float3 local translations.
  - id: bone_rel_b_offset
    type: u4
    doc: >-
      Absolute offset of a second required num_bones × float3 relation table.
      It is validated by the reader but not yet assigned a semantic role.
  - id: unknown_40
    size: 4
    doc: Unknown word at 0x40.
  - id: num_materials
    type: u4
    doc: Number of material records; nintoolbox permits at most 4096.
  - id: material_offset_table
    type: u4
    doc: Absolute offset of num_materials u32 offsets relative to material_base.
  - id: material_base
    type: u4
    doc: Absolute base address to which a material-table entry is added.
  - id: num_meshes
    type: u4
    doc: Number of meshes; nintoolbox accepts 1..4096.
  - id: mesh_offset_table
    type: u4
    doc: Absolute offset of num_meshes u32 offsets relative to mesh_base.
  - id: mesh_base_offset
    type: u4
    doc: Absolute base address for mesh records.
  - id: unknown_5c
    size: 0x70 - 0x5c
    doc: Unknown header bytes at 0x5c..0x6f.
  - id: shader_table_offset
    type: u4
    doc: >-
      Optional absolute shader-name table.  When present it has one 16-byte
      record per material; individual record semantics are not established.
  - id: texture_table_offset
    type: u4
    doc: >-
      Optional absolute texture table: a u32 count followed by 8-byte
      (hash, type) records.
  - id: reserved
    size: 8
    doc: Reserved final header bytes at 0x78..0x7f.
instances:
  bone_parents:
    pos: bone_hierarchy_offset
    type: s2
    repeat: expr
    repeat-expr: num_bones
    if: num_bones != 0
    doc: Signed parent-joint indexes; -1 identifies a root bone.
  bone_translations_a:
    pos: bone_rel_a_offset
    type: vec3
    repeat: expr
    repeat-expr: num_bones
    if: num_bones != 0
    doc: First per-bone local translation table.
  bone_translations_b:
    pos: bone_rel_b_offset
    type: vec3
    repeat: expr
    repeat-expr: num_bones
    if: num_bones != 0
    doc: Second validated per-bone float3 relation table.
  material_offsets:
    pos: material_offset_table
    type: u4
    repeat: expr
    repeat-expr: num_materials
    if: num_materials != 0
    doc: Material-relative offsets; each must lead to at least a 0x38-byte record.
  mesh_offsets:
    pos: mesh_offset_table
    type: u4
    repeat: expr
    repeat-expr: num_meshes
    doc: Mesh-relative offsets; each must lead to at least a 0x40-byte record.
  texture_count:
    pos: texture_table_offset
    type: u4
    if: texture_table_offset != 0
    doc: Count of optional texture hash/type records (accepted up to 4096).
  textures:
    pos: texture_table_offset + 4
    type: texture_record
    repeat: expr
    repeat-expr: texture_count
    if: texture_table_offset != 0
    doc: Optional texture references after texture_count.
types:
  vec3:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
  texture_record:
    seq:
      - id: hash
        type: u4
        doc: Texture identifier/hash.
      - id: type
        type: u4
        doc: Texture-reference type code.
