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
  parser validated against 7864 retail models.
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
