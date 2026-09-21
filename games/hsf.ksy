meta:
  id: hsf
  file-extension: hsf
  endian: be
  title: HAL Laboratory "HSFV037" model (Mario Party 4-8, Kirby Air Ride, Battalion Wars)
doc: |
  HAL Laboratory's tool-export model format (their "sysdolphin" GX runtime
  -- the same JObj/DObj/PObj/MObj/TObj object model documented in the
  public Kirby Air Ride decompilation, doldecomp/kar). Shipped as .hsf by
  Mario Party 4-8 and extracted from Mario Party's MPBIN container by
  wmpbdump; the same tool family also appears in Kirby Air Ride, Battalion
  Wars and other GameCube/Wii titles. Independently cross-checked against
  Hudson's GPL `hsfview` runtime sources and Nokonoko Estate's parser, on
  top of real retail Mario Party 4 data (board pieces and characters).

  A fixed 20-entry top-level table of { offset, count } pairs starts right
  after the "HSFV037" magic, followed by the string pool's own offset and
  byte length -- every `ofs_name`/`ofs_target`/etc. field anywhere in this
  format is a byte offset into that pool, NUL-terminated.

  Five entries (`colors`, `positions`, `normals`, `uvs`, `faces`) are
  AttributeHeader-shaped: `count` 12-byte records, one per independently-
  named mesh part, each in turn pointing at that part's own data (see
  `attribute_header` below). A `count > 1` AttributeHeader array is not N
  repeated raw data blocks; it is N independently-named mesh parts,
  addressed indirectly through their own per-part headers rather than
  sizes in the top table -- this is what a real multi-part or skinned
  character model's positions/faces sections look like, and getting this
  wrong makes every such model (as opposed to the simpler count==1 case)
  look unsupported. A single-part model still has a length-1 array here --
  there is no separate "no sub-parts" layout.

  Every other entry (`materials`, `attributes`, `nodes`, `textures`,
  `palettes`, `parts`, `clusters`, `shapes`, `scene`, `map_attr`) instead
  points straight at a flat array of `count` fixed-size records, with no
  AttributeHeader indirection -- their record sizes were recovered from
  Hudson's hsfview runtime loader and independently corroborated by
  Nokonoko Estate and real retail Mario Party 4 data.

  Normals additionally have two on-disk variants for the *data* an
  attribute_header points at: the common 3x big-endian f32 XYZ, or, in
  some real sections, 3 signed bytes (value/127.0) 0x20-byte aligned --
  detected by whether a second per-mesh normal header's data_off lines up
  with the first header's byte-packed (rather than float) end. Only the
  float variant is modeled below (`vec3f`); the packed-byte variant is
  documented but left for a decoder to special-case.

  `motions`' keyframe payloads and `faces`' type-4 extended-vertex pool sit
  in shared pools whose base address is a running sum/max across every
  record in the array (every motion's track table, or every face part's
  primitive-table byte length, respectively) rather than a fixed offset --
  not expressible as a single field here, so those pools are documented in
  the relevant `doc` strings but not parsed.
seq:
  - id: magic
    contents: "HSFV037"
  - id: pad
    size: 1
  - id: entries
    type: top_entry
    repeat: expr
    repeat-expr: 20
  - id: ofs_str_pool
    type: u4
    doc: Byte offset of the NUL-terminated string pool every name/target offset in this file indexes into.
  - id: len_str_pool
    type: u4
    doc: Byte length of the string pool.
instances:
  str_pool:
    pos: ofs_str_pool
    size: len_str_pool
    doc: Raw NUL-terminated string pool; slice from an `ofs_name` to the next NUL to resolve a name.

  scene_entries:
    pos: entries[0].ofs_body
    type: scene_entry
    repeat: expr
    repeat-expr: entries[0].count
    if: entries[0].ofs_body != 0 and entries[0].count > 0
  color_parts:
    pos: entries[1].ofs_body
    type: attribute_header(1, entries[1].ofs_body + entries[1].count * 12)
    repeat: expr
    repeat-expr: entries[1].count
    if: entries[1].ofs_body != 0 and entries[1].count > 0
  materials:
    pos: entries[2].ofs_body
    type: material
    repeat: expr
    repeat-expr: entries[2].count
    if: entries[2].ofs_body != 0 and entries[2].count > 0
  attributes:
    pos: entries[3].ofs_body
    type: attribute_record
    repeat: expr
    repeat-expr: entries[3].count
    if: entries[3].ofs_body != 0 and entries[3].count > 0
  position_parts:
    pos: entries[4].ofs_body
    type: attribute_header(4, entries[4].ofs_body + entries[4].count * 12)
    repeat: expr
    repeat-expr: entries[4].count
    if: entries[4].ofs_body != 0 and entries[4].count > 0
  normal_parts:
    pos: entries[5].ofs_body
    type: attribute_header(5, entries[5].ofs_body + entries[5].count * 12)
    repeat: expr
    repeat-expr: entries[5].count
    if: entries[5].ofs_body != 0 and entries[5].count > 0
  uv_parts:
    pos: entries[6].ofs_body
    type: attribute_header(6, entries[6].ofs_body + entries[6].count * 12)
    repeat: expr
    repeat-expr: entries[6].count
    if: entries[6].ofs_body != 0 and entries[6].count > 0
  face_parts:
    pos: entries[7].ofs_body
    type: attribute_header(7, entries[7].ofs_body + entries[7].count * 12)
    repeat: expr
    repeat-expr: entries[7].count
    if: entries[7].ofs_body != 0 and entries[7].count > 0
  nodes:
    pos: entries[8].ofs_body
    type: node
    repeat: expr
    repeat-expr: entries[8].count
    if: entries[8].ofs_body != 0 and entries[8].count > 0
  textures:
    pos: entries[9].ofs_body
    type: texture
    repeat: expr
    repeat-expr: entries[9].count
    if: entries[9].ofs_body != 0 and entries[9].count > 0
  palettes:
    pos: entries[10].ofs_body
    type: palette
    repeat: expr
    repeat-expr: entries[10].count
    if: entries[10].ofs_body != 0 and entries[10].count > 0
  motions:
    pos: entries[11].ofs_body
    type: motion
    repeat: expr
    repeat-expr: entries[11].count
    if: entries[11].ofs_body != 0 and entries[11].count > 0
  parts:
    pos: entries[14].ofs_body
    type: part
    repeat: expr
    repeat-expr: entries[14].count
    if: entries[14].ofs_body != 0 and entries[14].count > 0
  clusters:
    pos: entries[15].ofs_body
    type: cluster
    repeat: expr
    repeat-expr: entries[15].count
    if: entries[15].ofs_body != 0 and entries[15].count > 0
  shapes:
    pos: entries[16].ofs_body
    type: shape
    repeat: expr
    repeat-expr: entries[16].count
    if: entries[16].ofs_body != 0 and entries[16].count > 0
  map_attrs:
    pos: entries[17].ofs_body
    type: map_attr_entry
    repeat: expr
    repeat-expr: entries[17].count
    if: entries[17].ofs_body != 0 and entries[17].count > 0
  matrix_section:
    pos: entries[18].ofs_body
    type: matrix_section
    if: entries[18].ofs_body != 0 and entries[18].count > 0
  num_symbols:
    value: 'entries[19].ofs_body != 0 and ofs_str_pool > entries[19].ofs_body ? (ofs_str_pool - entries[19].ofs_body) / 4 : 0'
    doc: |
      Hudson writes the symbol section's own top-level `count` as a number
      of symbol *groups*, not the number of u4 indices actually stored --
      so the real element count is derived from where the next section
      (the string pool) begins instead of trusted directly.
  symbols:
    pos: entries[19].ofs_body
    type: u4
    repeat: expr
    repeat-expr: num_symbols
    if: entries[19].ofs_body != 0 and num_symbols > 0
    doc: Flat pool of indices into other sections (e.g. `attributes`, `position_parts`), addressed by a base+count pair stored elsewhere (materials' texture list, a mesh node's morph-target list, ...).
enums:
  top_index:
    0: scene
    1: colors
    2: materials
    3: attributes
    4: positions
    5: normals
    6: uvs
    7: faces
    8: nodes
    9: textures
    10: palettes
    11: motions
    12: envelopes
    # 13 is deliberately absent: no known real file populates it, and the
    # decoder's own HSF_IDX_* table (lib-hsf.c) skips straight from 12 to
    # 14 -- an unused directory slot, not a modeling gap.
    14: parts
    15: clusters
    16: shapes
    17: map_attr
    18: matrices
    19: symbols
  node_kind:
    0: joint
    1: replica
    2: mesh
    7: camera
    8: light
  face_kind:
    2: triangle
    3: quad
    4: indexed_strip
types:
  vec3f:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
  vec2f:
    seq:
      - id: u
        type: f4
      - id: v
        type: f4
  rgba8:
    seq:
      - id: r
        type: u1
      - id: g
        type: u1
      - id: b
        type: u1
      - id: a
        type: u1

  top_entry:
    doc: |
      One directory slot. `count` is an AttributeHeader count for the five
      attribute-shaped entries (`colors`, `positions`, `normals`, `uvs`,
      `faces`) and a plain fixed-size record count for every other entry
      -- see the format `doc` above.
    seq:
      - id: ofs_body
        type: u4
        doc: File offset of this entry's body; 0 when the section is absent (e.g. `envelopes` on an unskinned model).
      - id: count
        type: u4
        doc: Number of records in this entry's body.

  attribute_header:
    doc: |
      One named mesh part's sub-table: `data_count` records of this
      attribute's data, starting `data_off` bytes after the end of the
      whole AttributeHeader array this record belongs to.
    params:
      - id: kind
        type: u4
        doc: The owning top-level entry's `top_index` value; selects `data`'s record type.
      - id: body_base
        type: u4
        doc: Absolute file offset right after the whole AttributeHeader array (shared by every header in that array).
    seq:
      - id: ofs_name
        type: u4
        doc: Offset into the string pool of this part's name.
      - id: data_count
        type: u4
        doc: |
          Number of attribute records for this part. For `faces`, each
          record is a fixed 48 bytes regardless of its own `type` field
          (triangle/quad/indexed-strip all reserve the same space) --
          `data_count * 48` is a `faces` part's exact byte length.
      - id: ofs_data
        type: u4
        doc: Byte offset of this part's data, relative to `body_base`.
    instances:
      data:
        pos: body_base + ofs_data
        repeat: expr
        repeat-expr: data_count
        type:
          switch-on: kind
          cases:
            1: rgba8
            4: vec3f
            5: vec3f
            6: vec2f
            7: face_record
        doc: |
          `kind == 5` (normals) only covers the common packed-float
          layout; some real files instead pack normals as 3 signed bytes
          (value/127.0), 0x20-byte aligned -- see the format `doc` above.

  face_record:
    doc: |
      One face. `type` selects how the 44-byte body is read; all three
      variants reserve the same 44 bytes, which is why a `faces` part's
      byte length is always `data_count * 48` regardless of the mix of
      triangles/quads/strips inside it.
    seq:
      - id: type
        type: s2
        enum: face_kind
      - id: material_raw
        type: s2
        doc: Material index; the real index is `material_raw & 0xfff`.
      - id: body
        type:
          switch-on: type
          cases:
            'face_kind::quad': quad_body
            'face_kind::indexed_strip': strip_body
            _: tri_body
    instances:
      material:
        value: material_raw & 0xfff
  vertex_group:
    doc: One vertex's {position,normal,color,uv} attribute indices.
    seq:
      - id: position_idx
        type: s2
      - id: normal_idx
        type: s2
      - id: color_idx
        type: s2
      - id: uv_idx
        type: s2
  tri_body:
    doc: face_kind::triangle -- 3 vertex_groups (0-1-2); the reserved 4th group slot is unused padding.
    seq:
      - id: groups
        type: vertex_group
        repeat: expr
        repeat-expr: 3
      - id: unused
        size: 20
  quad_body:
    doc: face_kind::quad -- 4 vertex_groups, triangulated by the consumer as 0-1-2 and 1-3-2.
    seq:
      - id: groups
        type: vertex_group
        repeat: expr
        repeat-expr: 4
      - id: unused
        size: 12
  strip_body:
    doc: |
      face_kind::indexed_strip -- 3 explicit vertex_groups (matching
      corners 0-1-2), then a count of and byte-offset to additional
      vertex_groups in a pool shared by every strip/fan record in this
      `faces` part. That pool sits right after all of this part's own
      48-byte records, at a base that is itself the running sum of every
      *other* face part's `data_count * 48` in file order -- a
      cross-record computation this `.ksy` does not attempt, so
      `extra_count`/`extra_offset` are exposed raw rather than resolved.
    seq:
      - id: groups
        type: vertex_group
        repeat: expr
        repeat-expr: 3
      - id: extra_count
        type: s4
      - id: extra_offset
        type: u4
        doc: Offset, in 8-byte vertex_group units, into the shared extra-vertex pool.
      - id: unused
        size: 12

  node:
    doc: |
      One HSF_IDX_NODES record (`0x144` bytes). Raw node-table entries mix
      true hierarchy joints (`node_kind::joint`), mesh-definition nodes
      (`node_kind::mesh`, one per named mesh, carrying its morph-target
      list) and replica/instance nodes (`node_kind::replica`) in the same
      index space, alongside camera and light records which reuse the
      same 0x144-byte slot for unrelated fields. Types other than the five
      named here are real, transform-bearing entries too (the loader
      treats every `type <= 6` as hierarchy/TRS-shaped) -- just not yet
      individually identified.
    seq:
      - id: ofs_name
        type: u4
        doc: Offset into the string pool of this node's name.
      - id: type
        type: u4
        enum: node_kind
      - id: unknown_08
        size: 8
      - id: body
        type:
          switch-on: type
          cases:
            'node_kind::camera': camera_body
            'node_kind::light': light_body
            _: joint_body
        doc: node_kind::joint, node_kind::replica, node_kind::mesh and every unidentified `type <= 6` all share `joint_body`'s layout.
  joint_body:
    doc: |
      Hierarchy/TRS-shaped node body (every `type <= 6`). `replica_target_node`
      is only meaningful on a `node_kind::replica` node (index of the node
      whose subtree it instances); `num_morph_targets`/`morph_target_sym_start`
      are only meaningful on a `node_kind::mesh` node (a run of that many
      indices in `symbols`, starting at that index, each naming an
      alternate `position_parts` entry to use as a morph target).
    seq:
      - id: parent_idx
        type: s4
        doc: Index into `nodes` of this node's parent, or -1 at a root.
      - id: unknown_04
        size: 8
      - id: translate
        type: vec3f
      - id: rotate
        type: vec3f
        doc: Euler angles in degrees.
      - id: scale
        type: vec3f
      - id: unknown_30
        size: 36
      - id: replica_target_node
        type: s4
      - id: unknown_58
        size: 188
      - id: num_morph_targets
        type: u4
      - id: morph_target_sym_start
        type: u4
      - id: unknown_11c
        size: 24
  camera_body:
    seq:
      - id: position
        type: vec3f
      - id: target
        type: vec3f
      - id: roll_deg
        type: f4
      - id: yfov_deg
        type: f4
      - id: znear
        type: f4
      - id: zfar
        type: f4
      - id: unknown_28
        size: 268
  light_body:
    seq:
      - id: position
        type: vec3f
      - id: target
        type: vec3f
      - id: kind
        type: u1
        doc: 0 = directional, 1 = point, otherwise spot.
      - id: color
        type: rgba8
        doc: Only r/g/b are meaningful here; a/the 4th byte belongs to the next field.
      - id: unknown_1c
        size: 4
      - id: range
        type: f4
      - id: intensity
        type: f4
      - id: outer_cone_deg
        type: f4
      - id: unknown_2c
        size: 264

  material:
    doc: One HSF_IDX_MATERIALS record (60 bytes), from Mario Party's own decompiled HsfMaterial_s.
    seq:
      - id: ofs_name
        type: u4
      - id: unknown_04
        size: 7
      - id: ambient
        type: rgb8
        doc: litColor.
      - id: diffuse
        type: rgb8
        doc: color.
      - id: shadow_color
        type: rgb8
      - id: shininess
        type: f4
        doc: hiliteScale.
      - id: unknown_18
        size: 4
      - id: inv_alpha
        type: f4
        doc: Diffuse alpha is `1.0 - inv_alpha`.
      - id: unknown_20
        size: 20
      - id: num_textures
        type: u4
      - id: first_texture_symbol
        type: u4
        doc: Index of the first of `num_textures` consecutive entries in `symbols`, each naming an `attributes` record for one texture stage.
      - id: unknown_3c
        size: 4
  rgb8:
    seq:
      - id: r
        type: u1
      - id: g
        type: u1
      - id: b
        type: u1

  attribute_record:
    doc: One HSF_IDX_ATTRIBUTES record (132 bytes; "HsfAttribute_s"), one per texture-stage binding referenced from a `material` through `symbols`.
    seq:
      - id: unknown_00
        size: 40
      - id: tex_scale
        type: vec2f
      - id: tex_translate
        type: vec2f
      - id: unknown_38
        size: 44
      - id: wrap_s
        type: u4
      - id: wrap_t
        type: u4
      - id: unknown_6c
        size: 20
      - id: texture_idx
        type: s4
        doc: Index into `textures`, or -1/out-of-range if this attribute binds no texture.

  texture:
    doc: One HSF_IDX_TEXTURES record (32 bytes). Pixel data for the whole array follows immediately after it, at `ofs_pixel_data` relative to the end of this array; decoding it needs the referenced GX texture format and is out of scope here.
    seq:
      - id: ofs_name
        type: u4
      - id: unknown_04
        size: 4
      - id: format
        type: u1
        doc: GX texture format (raw encoder value; 7 maps to GX format 14 -- see lib-hsf.c's hsf_gx_size).
      - id: bits_per_pixel
        type: u1
      - id: width
        type: u2
      - id: height
        type: u2
      - id: unknown_0e
        size: 6
      - id: palette_idx
        type: s4
        doc: Index into `palettes`, or negative if this texture is not palettized.
      - id: unknown_18
        size: 4
      - id: ofs_pixel_data
        type: u4

  palette:
    doc: One HSF_IDX_PALETTES record (16 bytes). Palette pixel data for the whole array follows it, at `ofs_data` relative to the end of this array.
    seq:
      - id: unknown_00
        size: 4
      - id: format
        type: u4
      - id: num_colors
        type: u4
      - id: ofs_data
        type: u4

  part:
    doc: One HSF_IDX_PARTS record (12 bytes) -- a named vertex-buffer range, e.g. one skinned mesh's sub-range referenced from a `cluster`.
    seq:
      - id: ofs_name
        type: u4
      - id: vertex_count
        type: u4
      - id: vertex_offset
        type: u4

  cluster:
    doc: |
      One HSF_IDX_CLUSTERS record ("HSFCLUSTER", 0xA0 bytes): a morph or
      skin-weight driver. `ofs_name`/`ofs_alt_name` are the cluster's own
      names (some real files carry two); `ofs_target` is the mesh-part
      name this cluster's `weights` are lerped into.
    seq:
      - id: ofs_name
        type: u4
      - id: ofs_alt_name
        type: u4
      - id: ofs_target
        type: u4
      - id: part_idx
        type: s4
      - id: value
        type: f4
        doc: Current/default blend value.
      - id: weights
        type: f4
        repeat: expr
        repeat-expr: 32
      - id: adjusted
        type: u1
      - id: unknown_95
        type: u1
      - id: type
        type: u2
      - id: vertex_buffer_count
        type: u4
      - id: vertex_symbol_index
        type: u4
        doc: Index into `symbols` of this cluster's first bound vertex/index.

  shape:
    doc: One HSF_IDX_SHAPES record (12 bytes) -- a named morph-target shape buffer.
    seq:
      - id: ofs_name
        type: u4
      - id: kind
        type: u2
      - id: vertex_buffer_count
        type: u2
      - id: vertex_symbol_index
        type: u4

  scene_entry:
    doc: One HSF_IDX_SCENE record (16 bytes) -- per-scene fog settings.
    seq:
      - id: fog_type
        type: u4
      - id: fog_start
        type: f4
      - id: fog_end
        type: f4
      - id: fog_color
        type: rgba8

  map_attr_entry:
    doc: One HSF_IDX_MAP_ATTR record (24 bytes) -- an axis-aligned bounds volume paired with a data range, used by stage/map-specific tooling.
    seq:
      - id: bounds
        type: f4
        repeat: expr
        repeat-expr: 4
      - id: data_index
        type: u4
      - id: data_length
        type: u4

  matrix_section:
    doc: |
      HSF_IDX_MATRICES' single body: a 12-byte header followed by
      `num_matrices` affine 3x4 matrices. The top-level directory's own
      `count` for this entry is just a presence flag (0 or 1); the real
      matrix count is `num_matrices` here.
    seq:
      - id: base_index
        type: u4
      - id: num_matrices
        type: u4
      - id: ofs_data
        type: u4
        doc: Byte offset of the matrix array, relative to the end of this 12-byte header.
    instances:
      matrices:
        pos: _root.entries[18].ofs_body + 12 + ofs_data
        type: affine_matrix
        repeat: expr
        repeat-expr: num_matrices
  affine_matrix:
    doc: 3x4 affine matrix, row-major.
    seq:
      - id: values
        type: f4
        repeat: expr
        repeat-expr: 12

  motion:
    doc: One HSF_IDX_MOTIONS header (16 bytes). `ofs_tracks` is relative to the end of the whole motion-header array (`entries[top_index::motions].ofs_body + entries[top_index::motions].count * 16`).
    seq:
      - id: ofs_name
        type: u4
      - id: num_tracks
        type: u4
      - id: ofs_tracks
        type: u4
      - id: num_frames
        type: f4
    instances:
      tracks:
        pos: _root.entries[11].ofs_body + _root.entries[11].count * 16 + ofs_tracks
        type: motion_track
        repeat: expr
        repeat-expr: num_tracks
  motion_track:
    doc: |
      One animation track (16 bytes): `mode` selects the target's kind
      (transform component, texture-matrix component, morph weight, ...)
      and `interpolation` the keyframe stride (8 bytes normally, 16 for
      interpolation mode 2). Keyframes live in a pool shared by every
      track of every motion, based at the end of the *last* motion's own
      track array -- a running max this `.ksy` does not compute, so
      `ofs_keys`/`num_keys` are exposed raw rather than resolved into an
      actual keyframe array.
    seq:
      - id: mode
        type: u1
      - id: unknown_01
        size: 1
      - id: target_symbol
        type: s2
        doc: Offset into the string pool naming this track's target, or -1.
      - id: value_index
        type: s2
      - id: effect
        type: s2
      - id: interpolation
        type: s2
      - id: num_keys
        type: s2
      - id: ofs_keys
        type: u4
