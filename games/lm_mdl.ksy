meta:
  id: lm_mdl
  file-extension: mdl
  application: Luigi's Mansion (GameCube)
  endian: be
doc: |
  Luigi's Mansion (GameCube) actor model. Ported from lib-lmmdl.c/.h
  (re-implemented from KillzXGaming/MdlConverter's GCNLibrary/LM/MDL,
  MIT-licensed; model research by opeyx, SpaceCats and the LM_Research
  wiki). Models the fixed 128-byte header (magic, element counts and
  absolute section offsets); the GX display-list packets, matrix and
  weight tables and embedded textures that follow are variable-layout
  binary data best consumed with the reference decoder rather than a
  fixed Kaitai type, so they are exposed here only as raw offsets/
  counts.
seq:
  - id: magic
    contents: [0x04, 0xb4, 0x00, 0x00]
  - id: num_faces
    type: u2
  - id: unknown_06
    type: u2
  - id: num_nodes
    type: u2
  - id: num_packets
    type: u2
  - id: num_weights
    type: u2
  - id: num_joints
    type: u2
  - id: num_verts
    type: u2
  - id: num_normals
    type: u2
  - id: num_colours
    type: u2
  - id: num_uvs
    type: u2
  - id: unknown_24
    size: 8
  - id: num_textures
    type: u2
  - id: unknown_22
    type: u2
  - id: num_samplers
    type: u2
  - id: num_elements
    type: u2
  - id: num_materials
    type: u2
  - id: num_shapes
    type: u2
  - id: unknown_2c
    size: 4
  - id: node_off
    type: u4
  - id: packet_off
    type: u4
    doc: Main + LOD shadow packets (two packet blocks back to back).
  - id: matrix_off
    type: u4
    doc: num_joints x 3x4 f32 inverse-bind matrices.
  - id: weight_off
    type: u4
  - id: joint_index_off
    type: u4
  - id: weight_count_off
    type: u4
  - id: vertex_off
    type: u4
  - id: normal_off
    type: u4
  - id: colour_off
    type: u4
  - id: uv_off
    type: u4
  - id: unknown_58
    size: 8
  - id: texture_off
    type: u4
    doc: num_textures x u32 absolute offsets to texture headers.
  - id: unknown_64
    size: 4
  - id: material_off
    type: u4
  - id: sampler_off
    type: u4
  - id: shape_off
    type: u4
  - id: element_off
    type: u4
    doc: num_elements x {u16 material, u16 shape}.
  - id: unknown_78
    size: 8
    doc: Padding to the fixed 128-byte header size.
types:
  texture_header:
    doc: 32-byte header preceding each embedded GX-tiled texture's pixels.
    seq:
      - id: format
        type: u1
        enum: gx_texture_format
      - id: padding
        type: u1
      - id: width
        type: u2
      - id: height
        type: u2
      - id: reserved
        size: 26
  material:
    doc: 32-byte material head followed by 8 TEV stages.
    seq:
      - id: colour_r
        type: u1
      - id: colour_g
        type: u1
      - id: colour_b
        type: u1
      - id: colour_a
        type: u1
      - id: unknown_04
        type: u2
      - id: alpha
        type: u1
      - id: num_tev_stages
        type: u1
      - id: unknown_08
        type: u1
      - id: padding
        size: 23
      - id: tev_stages
        type: tev_stage
        repeat: expr
        repeat-expr: 8
  tev_stage:
    seq:
      - id: unknown_00
        type: u2
      - id: sampler
        type: u2
      - id: params
        type: f4
        repeat: expr
        repeat-expr: 7
  sampler:
    seq:
      - id: texture_index
        type: u2
      - id: unknown_02
        type: u2
      - id: wrap_u
        type: u1
      - id: wrap_v
        type: u1
      - id: min_filter
        type: u1
      - id: mag_filter
        type: u1
  shape:
    seq:
      - id: normal_flags
        type: u1
      - id: unknown
        size: 3
      - id: packet_count
        type: u2
      - id: packet_begin
        type: u2
  draw_element:
    seq:
      - id: material_index
        type: u2
      - id: shape_index
        type: u2
  node:
    doc: |
      child/sibling are relative indices into the node array, not
      absolute offsets.
    seq:
      - id: index
        type: u2
      - id: child
        type: u2
      - id: sibling
        type: u2
      - id: unknown
        type: u2
      - id: shape_count
        type: u2
      - id: shape_index
        type: u2
      - id: padding
        type: u4
enums:
  gx_texture_format:
    3: i4
    4: i8
    5: ia4
    6: ia8
    7: rgb565
    8: rgb5a3
    9: rgba32
    0x0a: cmpr
