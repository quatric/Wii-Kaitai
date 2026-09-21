meta:
  id: mdl0
  file-extension: mdl0
  endian: be
  imports:
    - brres_sub_header
  title: NW4R MDL0 model
doc: |
  The 3D model sub-file of a BRRES: a bone tree, de-duplicated vertex /
  normal / colour / texture-coordinate arrays, GX display lists that index
  those arrays, and the materials that shade them.

  Everything inside is reached through offsets, and there are three
  different bases in play. Get one wrong and the file still "parses", it
  just yields nonsense -- so, spelled out:

  * the **section offsets** in the header are relative to the start of the
    MDL0;
  * a **resource entry's** `ofs_name` and `ofs_data` are relative to the
    start of the group that holds the entry;
  * a **node's own** name offset (bone, object, material, texture ref) is
    relative to the start of that node.

  Versions 8 through 11 are in circulation. The section table grows from
  11 entries to 14 at version 10, and the *meaning* of the later indices
  shifts with it, which is why `ofs_materials` and friends are computed
  rather than read positionally. The mapping below is the one used by a
  parser validated against 7864 retail models. Mario Kart Wii, one of the
  more thoroughly documented retail users of this format (see Tockdom's
  MDL0 File Format page), ships version 11 models with the full 14-entry
  table.
seq:
  - id: header
    type: brres_sub_header
  - id: sections
    type: s4
    repeat: expr
    repeat-expr: 'header.version >= 11 ? 14 : (header.version >= 10 ? 13 : 11)'
    doc: |
      Offsets from the start of this MDL0 to each resource group. Zero
      means the model has no data of that kind, which is common -- a
      bone-only model has nothing but a bone group.

      The table grows with the version: 11 entries at versions 8 and 9,
      13 at version 10 (fur vectors and fur layers inserted at indices 6
      and 7), 14 at version 11 (user data appended). Getting the *count*
      wrong is quietly destructive rather than fatal -- the groups still
      resolve, but `ofs_name` and `props` are read from the wrong place,
      so the model loses its name and reports a garbage bounding box.
      Version 10 is rare enough to hide the mistake: exactly one model in
      a 4000-model retail extraction uses it.
  - id: ofs_name
    type: s4
    doc: Offset to the model's own name in the string pool.
  - id: props
    type: model_props
instances:
  ofs_definitions:
    value: sections[0]
  ofs_bones:
    value: sections[1]
  ofs_positions:
    value: sections[2]
  ofs_normals:
    value: sections[3]
  ofs_colors:
    value: sections[4]
  ofs_uvs:
    value: sections[5]
  ofs_fur_vectors:
    value: sections[6]
    if: header.version >= 10
  ofs_fur_layers:
    value: sections[7]
    if: header.version >= 10
  ofs_materials:
    value: 'header.version >= 10 ? sections[8] : sections[6]'
    doc: |
      Version 10 inserted fur vectors and fur layers at indices 6 and 7,
      pushing materials, shaders, objects and texture links up by two.
  ofs_objects:
    value: 'header.version >= 10 ? sections[10] : sections[8]'
  ofs_texture_links:
    value: 'header.version >= 10 ? sections[11] : sections[9]'

  name:
    pos: ofs_name - 4
    type: pooled_string
    if: ofs_name != 0 and ofs_name < _io.size

  definitions:
    pos: ofs_definitions
    type: resource_group(ofs_definitions, 0)
    if: ofs_definitions != 0
    doc: |
      Scene-graph command lists: `NodeTree` (bone parenting), `NodeMix`
      (weighted matrix nodes), `DrawOpa` and `DrawXlu` (which object is
      drawn with which material, and in what order). Their bodies are
      byte-coded command streams rather than structs, so they are left as
      raw bytes here.
  bones:
    pos: ofs_bones
    type: resource_group(ofs_bones, 1)
    if: ofs_bones != 0
  positions:
    pos: ofs_positions
    type: resource_group(ofs_positions, 2)
    if: ofs_positions != 0
  normals:
    pos: ofs_normals
    type: resource_group(ofs_normals, 3)
    if: ofs_normals != 0
  colors:
    pos: ofs_colors
    type: resource_group(ofs_colors, 4)
    if: ofs_colors != 0
  uvs:
    pos: ofs_uvs
    type: resource_group(ofs_uvs, 5)
    if: ofs_uvs != 0
  materials:
    pos: ofs_materials
    type: resource_group(ofs_materials, 6)
    if: ofs_materials != 0
  objects:
    pos: ofs_objects
    type: resource_group(ofs_objects, 7)
    if: ofs_objects != 0
  texture_links:
    pos: ofs_texture_links
    type: resource_group(ofs_texture_links, 8)
    if: ofs_texture_links != 0
types:
  model_props:
    doc: |
      Model-wide totals and the bounding box. `num_vertices` and
      `num_faces` are the summed totals over every object; on the sample
      tarantula they read 304 and 172, and the exported model has exactly
      172 triangles.
    seq:
      - id: len_props
        type: s4
        doc: 0x40 in every observed model.
      - id: ofs_mdl0
        type: s4
        doc: Negative offset back to the MDL0 start; equals -(position of this block).
      - id: scaling_rule
        type: s4
      - id: tex_matrix_mode
        type: s4
      - id: num_vertices
        type: s4
      - id: num_faces
        type: s4
      - id: ofs_orig_path
        type: s4
      - id: num_nodes
        type: s4
        doc: |
          Size of the model's matrix-node table. It is **not** a synonym
          for the bone count: measured over 4000 retail models it equalled
          the number of bones in 84%, was smaller in 15% and larger in 1%.
          Treat the bone group and the table at `ofs_bone_table` as
          authoritative and this as a hint.
      - id: version
        type: u1
      - id: reserved
        size: 3
      - id: ofs_bone_table
        type: s4
        doc: |
          Offset from this block to the matrix-node -> bone index table.
          0x40 in the sample, i.e. immediately after these fields.
      - id: min_extents
        type: vec3
      - id: max_extents
        type: vec3

  resource_group:
    doc: |
      Identical in shape to the BRRES container's group: entry 0 is a
      sentinel and `num_entries` excludes it.
    params:
      - id: base_ofs
        type: s4
      - id: kind
        type: u4
        doc: |
          Which node type this group's entries point at. Not stored in the
          file -- the group a node lives in is what gives it meaning, so
          the caller passes it down.
    seq:
      - id: len_group
        type: u4
      - id: num_entries
        type: u4
      - id: entries
        type: resource_entry(base_ofs, kind)
        repeat: expr
        repeat-expr: num_entries + 1

  resource_entry:
    params:
      - id: base_ofs
        type: s4
      - id: kind
        type: u4
    seq:
      - id: id
        type: u2
      - id: reserved
        type: u2
      - id: idx_left
        type: u2
      - id: idx_right
        type: u2
      - id: ofs_name
        type: s4
      - id: ofs_data
        type: s4
    instances:
      name:
        pos: base_ofs + ofs_name - 4
        type: pooled_string
        if: ofs_name != 0 and base_ofs + ofs_name < _io.size
      body:
        pos: base_ofs + ofs_data
        if: ofs_data != 0
        type:
          switch-on: kind
          cases:
            1: bone
            2: vertex_array
            3: normal_array
            5: uv_array
            6: material
            7: object

  bone:
    doc: |
      One joint. `transform` is the absolute bind matrix and
      `transform_inv` its inverse -- both are stored, so a skin can be
      posed without composing the parent chain. The TRS triple is the
      local transform relative to the parent.

      The four link offsets are relative to *this bone's* start, so a
      bone's parent is at `(position of this bone) + ofs_parent`.
    seq:
      - id: len_bone
        type: s4
      - id: ofs_mdl0
        type: s4
      - id: ofs_name
        type: s4
      - id: index
        type: s4
      - id: node_id
        type: s4
        doc: |
          Matrix-node id. This is what an object's display list references
          when it loads a position/normal matrix, so it is the join
          between the bone tree and the geometry.
      - id: flags
        type: u4
        doc: |
          Bit 0x20 is segment-scale-compensate: the bone ignores its
          parent's scale. Such a bone is not expressible as an inherited
          TRS chain, which is why exporters have to fall back to writing
          its matrix directly.
      - id: billboard_flags
        type: u4
      - id: billboard_index
        type: u4
      - id: scale
        type: vec3
      - id: rotation
        type: vec3
        doc: Euler angles in degrees, applied Z then Y then X.
      - id: translation
        type: vec3
      - id: min_extents
        type: vec3
      - id: max_extents
        type: vec3
      - id: ofs_parent
        type: s4
      - id: ofs_first_child
        type: s4
      - id: ofs_next
        type: s4
      - id: ofs_prev
        type: s4
      - id: ofs_user_data
        type: s4
      - id: transform
        type: f4
        repeat: expr
        repeat-expr: 12
        doc: Absolute bind matrix, 3x4 row-major.
      - id: transform_inv
        type: f4
        repeat: expr
        repeat-expr: 12
    instances:
      name:
        pos: _parent.base_ofs + _parent.ofs_data + ofs_name - 4
        type: pooled_string
        if: ofs_name != 0 and _parent.base_ofs + _parent.ofs_data + ofs_name < _io.size
        doc: |
          Unlike a resource entry's name, a node's name offset is measured
          from the node itself.

  vertex_array:
    doc: |
      A de-duplicated position array. Components may be stored as float or
      as fixed-point integers; when integral, `divisor` is the number of
      fractional bits, so the value is `raw / (1 << divisor)`.
    seq:
      - id: len_data
        type: s4
      - id: ofs_mdl0
        type: s4
      - id: ofs_data
        type: s4
      - id: ofs_name
        type: s4
      - id: index
        type: s4
      - id: is_xyz
        type: s4
        doc: 1 for three components per vertex, 0 for two.
      - id: component_type
        type: s4
        enum: gx_component_type
      - id: divisor
        type: u1
      - id: entry_stride
        type: u1
        doc: Bytes per vertex; the authoritative stride, whatever the type implies.
      - id: num_vertices
        type: u2
      - id: min_extents
        type: vec3
      - id: max_extents
        type: vec3
    instances:
      data:
        pos: _parent.base_ofs + _parent.ofs_data + ofs_data
        size: num_vertices * entry_stride
        doc: Raw component data; decode with `component_type` and `divisor`.

  normal_array:
    seq:
      - id: len_data
        type: s4
      - id: ofs_mdl0
        type: s4
      - id: ofs_data
        type: s4
      - id: ofs_name
        type: s4
      - id: index
        type: s4
      - id: is_nbt
        type: s4
        doc: Non-zero when the array carries normal+binormal+tangent triples.
      - id: component_type
        type: s4
        enum: gx_component_type
      - id: divisor
        type: u1
      - id: entry_stride
        type: u1
      - id: num_vertices
        type: u2
    instances:
      data:
        pos: _parent.base_ofs + _parent.ofs_data + ofs_data
        size: num_vertices * entry_stride

  uv_array:
    doc: Same shape as the position array; `is_st` is 1 for two components.
    seq:
      - id: len_data
        type: s4
      - id: ofs_mdl0
        type: s4
      - id: ofs_data
        type: s4
      - id: ofs_name
        type: s4
      - id: index
        type: s4
      - id: is_st
        type: s4
      - id: component_type
        type: s4
        enum: gx_component_type
      - id: divisor
        type: u1
      - id: entry_stride
        type: u1
      - id: num_entries
        type: u2
      - id: min_u
        type: f4
      - id: min_v
        type: f4
      - id: max_u
        type: f4
      - id: max_v
        type: f4
    instances:
      data:
        pos: _parent.base_ofs + _parent.ofs_data + ofs_data
        size: num_entries * entry_stride

  object:
    doc: |
      One drawable polygon group: a vertex descriptor plus two GX display
      lists. The descriptor half (`vertex_format_lo/hi`, `vertex_specs`)
      says which attributes each vertex in the primitive stream carries
      and how wide each index is; the primitive list then holds GX draw
      opcodes -- 0x80 quads, 0x90 triangles, 0x98 strips, 0xa0 fans --
      each followed by a u16 vertex count and that many index tuples.

      The vertices in every primitive are stored in the order the hardware
      consumes them, which is the reverse of the counter-clockwise winding
      COLLADA, OBJ and glTF expect.
    seq:
      - id: len_total
        type: s4
      - id: ofs_mdl0
        type: s4
      - id: node_id
        type: s4
        doc: Matrix node this object is attached to, or -1 when it is skinned.
      - id: vertex_format_lo
        type: u4
      - id: vertex_format_hi
        type: u4
        doc: |
          The GX CP vertex descriptor: two bits per attribute, saying
          whether it is absent, direct, or indexed by an 8- or 16-bit
          index.
      - id: vertex_specs
        type: u4
        doc: 'GX VAT entry: component counts and formats for each attribute.'
      - id: definitions
        type: prim_data_group
        doc: Display list that sets up the CP/XF state for this object.
      - id: primitives
        type: prim_data_group
        doc: Display list holding the actual draw commands.
      - id: array_flags
        type: u4
      - id: flag
        type: s4
      - id: ofs_name
        type: s4
      - id: index
        type: s4
      - id: num_vertices
        type: s4
      - id: num_faces
        type: s4
      - id: id_vertex
        type: s2
      - id: id_normal
        type: s2
      - id: id_color
        type: s2
        repeat: expr
        repeat-expr: 2
      - id: id_uv
        type: s2
        repeat: expr
        repeat-expr: 8
        doc: |
          Index of the UV array each texture-coordinate slot reads, or -1
          when the slot is unused. A material samples a specific slot, so
          this is what ties a texture to the right coordinates.
    instances:
      name:
        pos: _parent.base_ofs + _parent.ofs_data + ofs_name - 4
        type: pooled_string
        if: ofs_name != 0 and _parent.base_ofs + _parent.ofs_data + ofs_name < _io.size

  prim_data_group:
    doc: |
      A display list: `len_buffer` bytes reserved, `len_data` bytes used,
      at `ofs_data` measured from the start of this three-field record.
    seq:
      - id: len_buffer
        type: s4
      - id: len_data
        type: s4
      - id: ofs_data
        type: s4
    instances:
      self_ofs:
        value: _io.pos - 12
        doc: Absolute position this record started at; ofs_data is relative to it.
      commands:
        pos: self_ofs + ofs_data
        size: len_data
        type: gx_command_stream(_parent.vertex_format_lo, _parent.vertex_format_hi)
        if: len_data > 0
        doc: |
          The raw GX command stream, decoded generically. See
          `gx_command`/`gx_opcode`: draw commands are fully expanded into
          per-vertex attribute indices using this object's vertex
          descriptor (`vertex_format_lo/hi`); CP/XF register loads are
          exposed as (register, value) pairs without interpreting what
          the register controls.

  gx_command_stream:
    doc: |
      A GX FIFO command stream as found in an MDL0 object's `definitions`
      (CP/XF setup) and `primitives` (draw calls) display lists. Layout
      per the GameCube/Wii GX command format (yagcd chap.6, Dolphin's
      OpcodeDecoding.cpp/CPMemory.h) -- this is fixed console hardware
      behaviour, not something specific to this file format.
    params:
      - id: vcd_lo
        type: u4
      - id: vcd_hi
        type: u4
    seq:
      - id: commands
        type: gx_command(vcd_lo, vcd_hi)
        repeat: eos

  gx_command:
    params:
      - id: vcd_lo
        type: u4
      - id: vcd_hi
        type: u4
    seq:
      - id: opcode
        type: u1
        enum: gx_opcode
      - id: body
        type:
          switch-on: opcode
          cases:
            gx_opcode::draw_quads: primitive_body(vcd_lo, vcd_hi)
            gx_opcode::draw_triangles: primitive_body(vcd_lo, vcd_hi)
            gx_opcode::draw_triangle_strip: primitive_body(vcd_lo, vcd_hi)
            gx_opcode::draw_triangle_fan: primitive_body(vcd_lo, vcd_hi)
            gx_opcode::draw_lines: primitive_body(vcd_lo, vcd_hi)
            gx_opcode::draw_line_strip: primitive_body(vcd_lo, vcd_hi)
            gx_opcode::draw_points: primitive_body(vcd_lo, vcd_hi)
            gx_opcode::load_cp_reg: cp_reg_load
            gx_opcode::load_xf_reg: xf_reg_load
            gx_opcode::load_indx_a: indx_load
            gx_opcode::load_indx_b: indx_load
            gx_opcode::load_indx_c: indx_load
            gx_opcode::load_indx_d: indx_load
        doc: |
          `nop` (0x00, used as padding/alignment) has no body and is not
          listed above, so it naturally consumes only the opcode byte.
          Any other opcode this project's exporters do not emit will fail
          to parse past this point rather than silently misreading the
          stream.

  cp_reg_load:
    doc: 'GX_LOAD_CP_REG (0x08): one CP register write.'
    seq:
      - id: register
        type: u1
      - id: value
        type: u4

  xf_reg_load:
    doc: 'GX_LOAD_XF_REG (0x10): a run of consecutive XF register writes.'
    seq:
      - id: len_minus_1
        type: u2
      - id: address
        type: u2
      - id: values
        type: u4
        repeat: expr
        repeat-expr: len_minus_1 + 1

  indx_load:
    doc: |
      GX_LOAD_INDX_A/B/C/D (0x20/0x28/0x30/0x38): loads one row of an XF
      index-driven array (used for e.g. normal-matrix or light objects)
      by index. `packed_addr_len`'s low 12 bits are the XF destination
      address and its high 4 bits are (row length in u32s) - 1.
    seq:
      - id: index
        type: u2
      - id: packed_addr_len
        type: u2

  primitive_body:
    params:
      - id: vcd_lo
        type: u4
      - id: vcd_hi
        type: u4
    seq:
      - id: num_vertices
        type: u2
      - id: vertices
        type: gx_vertex(vcd_lo, vcd_hi)
        repeat: expr
        repeat-expr: num_vertices

  gx_vertex:
    doc: |
      One vertex's worth of attribute indices, in GX hardware order.
      Matrix-index attributes are single presence bits in `vcd_lo`
      (always a direct byte when present); Position/Normal/Color0-1
      (`vcd_lo`) and TexCoord0-7 (`vcd_hi`) are each a 2-bit format code
      (0 none, 1 direct, 2 index8, 3 index16). No MDL0 exporter for this
      format emits direct-format Position/Normal/Color/TexCoord data --
      only the matrix-index bits ever use a raw byte -- so format 1 is
      intentionally left unhandled below; a file that did use it would
      fail to parse rather than silently desyncing the vertex stream.
    params:
      - id: vcd_lo
        type: u4
      - id: vcd_hi
        type: u4
    seq:
      - id: pos_mtx_idx
        type: u1
        if: (vcd_lo & 1) != 0
      - id: tex0_mtx_idx
        type: u1
        if: ((vcd_lo >> 1) & 1) != 0
      - id: tex1_mtx_idx
        type: u1
        if: ((vcd_lo >> 2) & 1) != 0
      - id: tex2_mtx_idx
        type: u1
        if: ((vcd_lo >> 3) & 1) != 0
      - id: tex3_mtx_idx
        type: u1
        if: ((vcd_lo >> 4) & 1) != 0
      - id: tex4_mtx_idx
        type: u1
        if: ((vcd_lo >> 5) & 1) != 0
      - id: tex5_mtx_idx
        type: u1
        if: ((vcd_lo >> 6) & 1) != 0
      - id: tex6_mtx_idx
        type: u1
        if: ((vcd_lo >> 7) & 1) != 0
      - id: tex7_mtx_idx
        type: u1
        if: ((vcd_lo >> 8) & 1) != 0
      - id: position
        type: gx_vertex_attr((vcd_lo >> 9) & 3)
      - id: normal
        type: gx_vertex_attr((vcd_lo >> 11) & 3)
      - id: color0
        type: gx_vertex_attr((vcd_lo >> 13) & 3)
      - id: color1
        type: gx_vertex_attr((vcd_lo >> 15) & 3)
      - id: tex0_coord
        type: gx_vertex_attr((vcd_hi >> 0) & 3)
      - id: tex1_coord
        type: gx_vertex_attr((vcd_hi >> 2) & 3)
      - id: tex2_coord
        type: gx_vertex_attr((vcd_hi >> 4) & 3)
      - id: tex3_coord
        type: gx_vertex_attr((vcd_hi >> 6) & 3)
      - id: tex4_coord
        type: gx_vertex_attr((vcd_hi >> 8) & 3)
      - id: tex5_coord
        type: gx_vertex_attr((vcd_hi >> 10) & 3)
      - id: tex6_coord
        type: gx_vertex_attr((vcd_hi >> 12) & 3)
      - id: tex7_coord
        type: gx_vertex_attr((vcd_hi >> 14) & 3)

  gx_vertex_attr:
    doc: |
      One attribute's index within a vertex: absent (0 bytes), an 8-bit
      array index, or a 16-bit array index. `index` is looked up in the
      corresponding array (`object.id_vertex`/`id_normal`/`id_color`/
      `id_uv` say which array of that kind) to get the actual component
      values.
    params:
      - id: fmt
        type: u1
    seq:
      - id: index
        type:
          switch-on: fmt
          cases:
            2: u1
            3: u2
        if: fmt != 0

  material:
    doc: |
      Only the parts with a settled meaning are broken out here. The rest
      of a material is GX TEV state and a display list of register writes,
      which is a bytecode stream rather than a struct.

      `ofs_display_list` moves with the version -- 0x38 up to version 9,
      0x3c from version 10 -- because version 10 inserted a field earlier
      in the record.
    seq:
      - id: len_material
        type: s4
      - id: ofs_mdl0
        type: s4
      - id: ofs_name
        type: s4
      - id: index
        type: s4
      - id: flags
        type: u4
      - id: unknown
        size: 0x18
      - id: num_texture_refs
        type: u4
      - id: ofs_texture_refs
        type: s4
        doc: Offset from the start of this material to the first texture ref.
    instances:
      self_ofs:
        value: _parent.base_ofs + _parent.ofs_data
      name:
        pos: self_ofs + ofs_name - 4
        type: pooled_string
        if: ofs_name != 0 and self_ofs + ofs_name < _io.size
      texture_refs:
        pos: self_ofs + ofs_texture_refs
        type: texture_ref(self_ofs + ofs_texture_refs + _index * 0x34)
        repeat: expr
        repeat-expr: num_texture_refs
        if: ofs_texture_refs > 0 and num_texture_refs > 0

  texture_ref:
    params:
      - id: self_ofs
        type: s4
        doc: |
          Absolute offset of this 0x34-byte record, passed down so the
          self-relative name offset can be resolved without depending on
          where the stream happens to be parked.
    doc: |
      One texture layer. The wrap and filter fields were confirmed on a
      retail corpus by the fact that they only ever hold their legal enum
      values; a misread layout would show arbitrary dwords there.
    seq:
      - id: ofs_texture_name
        type: s4
        doc: Self-relative offset to the TEX0 name this layer samples.
      - id: ofs_palette_name
        type: s4
      - id: ofs_texture_data
        type: s4
      - id: ofs_palette_data
        type: s4
      - id: id_texture
        type: s4
      - id: id_palette
        type: s4
      - id: wrap_s
        type: u4
        enum: gx_wrap_mode
      - id: wrap_t
        type: u4
        enum: gx_wrap_mode
      - id: min_filter
        type: u4
      - id: mag_filter
        type: u4
      - id: lod_bias
        type: f4
      - id: max_anisotropy
        type: u4
      - id: clamp_bias
        type: u1
      - id: texel_interpolate
        type: u1
      - id: reserved
        type: u2
    instances:
      texture_name:
        pos: self_ofs + ofs_texture_name - 4
        type: pooled_string
        if: ofs_texture_name != 0 and self_ofs + ofs_texture_name < _io.size
        doc: |
          The bounds test is not paranoia. Inside an intact BRRES this
          always resolves, but tools that extract an MDL0 to its own file
          rebuild a shorter string pool and, on version 8 and 9 layouts,
          do not rewrite these particular ref fields -- so a detached v9
          chunk can carry an offset pointing past its own end. Three
          models in a 4000-model extraction do exactly that.

  pooled_string:
    seq:
      - id: len_name
        type: u4
      - id: name
        type: str
        size: len_name
        encoding: ASCII

  vec3:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
enums:
  gx_component_type:
    0: u8
    1: s8
    2: u16
    3: s16
    4: f32
  gx_wrap_mode:
    0: clamp
    1: repeat
    2: mirror
  gx_opcode:
    0x00: nop
    0x08: load_cp_reg
    0x10: load_xf_reg
    0x20: load_indx_a
    0x28: load_indx_b
    0x30: load_indx_c
    0x38: load_indx_d
    0x80: draw_quads
    0x90: draw_triangles
    0x98: draw_triangle_strip
    0xa0: draw_triangle_fan
    0xa8: draw_line_strip
    0xb0: draw_lines
    0xb8: draw_points
