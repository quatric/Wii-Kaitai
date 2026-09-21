meta:
  id: bnfm
  file-extension: bnfm
  endian: be
  title: Nd Cube BNFM 3D model
doc: |
  A Wii U-generation 3D model format from Nd Cube (*Animal Crossing:
  amiibo Festival*, *Mario Party 10*, *Wii U Party*). No magic; the
  header is a fixed set of big-endian offset/count fields into a face
  (index) buffer, an interleaved 44-byte-stride vertex buffer, a bone
  array, per-mesh "poly info" records and a material array. All name
  fields are `bnfm_string` offsets (relative to file start; the string
  itself is a plain NUL-terminated ASCII run at that offset, with no
  length prefix on disk).

  There is a companion `.bnfmsa` skeletal-animation format (10 SRT
  tracks per bone, Normal/Hermite keys) that this definition does not
  cover.
seq:
  - id: unknown1
    size: 0x0c
  - id: ofs_faces
    type: u4
  - id: len_faces
    type: u4
  - id: len_vertices
    type: u4
  - id: unknown2
    size: 8
  - id: ofs_vertices
    type: u4
  - id: unknown3
    size: 12
  - id: num_bones
    type: u4
  - id: num_meshes
    type: u4
  - id: len_materials
    type: u4
    doc: Total byte length of the material array; the reference decoder derives `num_materials` from this divided by 6 (rounding up to at least 1), not from a stored count.
  - id: unknown4
    size: 28
  - id: ofs_bones
    type: u4
  - id: ofs_poly_infos
    type: u4
  - id: ofs_materials
    type: u4
instances:
  num_indices:
    value: len_faces / 2
  num_vertices_total:
    value: len_vertices / 44
  num_materials:
    value: 'len_materials > 0 ? (len_materials / 6 > 0 ? len_materials / 6 : 1) : 1'
  indices:
    io: _root._io
    pos: ofs_faces
    type: u2
    repeat: expr
    repeat-expr: num_indices
  vertices:
    io: _root._io
    pos: ofs_vertices
    type: vertex
    repeat: expr
    repeat-expr: num_vertices_total
  bones:
    io: _root._io
    pos: ofs_bones
    type: bone
    repeat: expr
    repeat-expr: num_bones
    if: num_bones > 0 and ofs_bones < _root._io.size
  poly_infos:
    io: _root._io
    pos: ofs_poly_infos
    type: poly_info
    repeat: expr
    repeat-expr: num_meshes
    if: ofs_poly_infos > 0
  materials:
    io: _root._io
    pos: ofs_materials
    type: material
    repeat: expr
    repeat-expr: num_materials
types:
  bnfm_string:
    seq:
      - id: str
        type: strz
        encoding: ASCII
  vertex:
    doc: 44-byte interleaved vertex record.
    seq:
      - id: pos_x
        type: f4
      - id: pos_y
        type: f4
      - id: pos_z
        type: f4
      - id: normal_x
        type: s1
      - id: normal_y
        type: s1
      - id: normal_z
        type: s1
      - id: unknown1
        type: s1
      - id: color_r
        type: u1
      - id: color_g
        type: u1
      - id: color_b
        type: u1
      - id: color_a
        type: u1
      - id: texcoord_u
        type: u2
        doc: Half-float (binary16); not decoded further here.
      - id: texcoord_v
        type: u2
        doc: Half-float (binary16); not decoded further here.
      - id: unknown2
        size: 20
  bone:
    doc: 0xb0-byte bone record (only the first 0x88 bytes are ever read).
    seq:
      - id: ofs_name
        type: u4
      - id: unknown1
        type: u4
      - id: ofs_parent_name
        type: u4
      - id: unknown2
        size: 20
      - id: translate_x
        type: f4
      - id: translate_y
        type: f4
      - id: translate_z
        type: f4
      - id: scale_x
        type: f4
      - id: scale_y
        type: f4
      - id: scale_z
        type: f4
      - id: unknown3
        size: 16
      - id: inverse_bind
        type: f4
        repeat: expr
        repeat-expr: 12
        doc: 3x4 affine inverse-bind matrix, at record offset 0x48.
      - id: unknown4
        size: 0xb0 - 0x78
    instances:
      name:
        io: _root._io
        pos: ofs_name
        type: bnfm_string
        if: ofs_name != 0
      parent_name:
        io: _root._io
        pos: ofs_parent_name
        type: bnfm_string
        if: ofs_parent_name != 0
  poly_info:
    doc: 0x30-byte per-mesh record.
    seq:
      - id: ofs_name
        type: u4
      - id: unknown1
        size: 0x14
      - id: index_count
        type: u4
      - id: vertex_count
        type: u4
      - id: unknown2
        size: 4
      - id: material_idx
        type: u4
    instances:
      name:
        io: _root._io
        pos: ofs_name
        type: bnfm_string
        if: ofs_name != 0
  material:
    doc: 0x228-byte material record (only the first 0x118 bytes are ever read).
    seq:
      - id: ofs_name
        type: u4
      - id: unknown1
        size: 0x110
      - id: ofs_texture_name
        type: u4
      - id: unknown2
        size: 0x228 - 0x118
    instances:
      name:
        io: _root._io
        pos: ofs_name
        type: bnfm_string
        if: ofs_name != 0
      texture_name:
        io: _root._io
        pos: ofs_texture_name
        type: bnfm_string
        if: ofs_texture_name != 0
