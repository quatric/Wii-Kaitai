meta:
  id: hsd
  file-extension: dat
  endian: be
  title: HAL Laboratory "sysdolphin" (HSD) .dat archive
doc: |
  Serialized object-graph container used by Super Smash Bros. Melee, Kirby
  Air Ride and the Wii channel "Terebi no Tomo"/"TV no Tomo" (JPN). Not a
  directory-style archive: a flat blob of C structs starts at the 0x20 data
  base, and every inter-struct pointer is stored as an offset relative to
  that base, patched at load time via an explicit relocation table.

  Carries no magic number, so a decoder must validate the header shape
  itself (file size matching the real file size, relocation table
  placement, root/reference counts and the ASCII version tag) rather than
  checking a fixed byte string -- this is exactly what `IsHSD` in lib-hsd.c
  does before `ScanHSD` trusts the header.

  The header, relocation table, root/reference tables and string pool are
  modeled below, and so is the object graph itself: a JOBJ (joint) tree,
  each JOBJ optionally owning a chain of DOBJ (display object) nodes, each
  DOBJ optionally owning a chain of POBJ (polygon object) nodes holding
  the GX display-list opcode stream and vertex attribute arrays; DOBJs
  also reference MOBJ (material) and, through them, TOBJ (texture) nodes.
  `root_table` gives the exact, named entry points into this graph (e.g.
  "ToyBoxModel_TopN_joint" for a JOBJ root) rather than requiring a blind
  structural scan; `ref_table` names structs the file expects to be
  resolved externally (shared textures/animations across a title's files).
  Independently verified against 352 real "Ty*.dat" item/object files from
  a retail Super Smash Bros. Melee disc: 346 decode to correct, glTF-valid
  geometry, and byte-for-byte against a real file (TyBox.dat) before the
  layouts below were trusted: root table -> "ToyBoxModel_TopN_joint"
  resolved correctly; its DOBJ/POBJ chain's GX_Attribute array (POS
  index8/S16, NBT index8/F32, TEX0/TEX1 index8/S16 sharing one buffer)
  predicted the real per-vertex tuple width the display list actually
  uses; and the position buffer -- found via the relocation table, not a
  raw-offset guess -- decoded to plausible small-object coordinates.

  Every pointer field below (anything named `ofs_*` that is not itself an
  offset into the string pool) is a 0x20-relative offset that must be
  resolved as `0x20 + ofs_x`, exactly like `ofs_reloc_table` above; the
  `_x` instance below each such field does that resolution and parses the
  pointed-to struct, or is absent if the pointer is null. The GX display-
  list opcode stream itself (`display_list` on `pobj`) is left as raw
  bytes -- it is a small stack machine over the attribute array above it,
  not a fixed record layout, and decoding it is what `ExportHSDModel`
  exists for, not this `.ksy`.

  Scope note: cull/depth/blend render state (MOBJ rendermode, PEDesc) and
  shape-animation morph-target display lists are structurally reachable
  below but not decoded further, matching lib-hsd.c's own "not yet
  exported" scope for those two.

  Several titles (e.g. Doraemon on GameCube) ship one file holding several
  complete HSD archives back to back, each with its own header and 0xCD
  fill between them -- not modeled here since it is a container-of-
  containers concern, not part of a single archive's layout.

  Ported from lib-hsd.c's `IsHSD`/`ScanHSD` and the header comment in
  lib-hsd.h, both cross-checked against Ploaj/HSDLib's HSDRawFile.cs
  (`Open()`, MIT licensed) for the relocation/root/reference parsing.
seq:
  - id: file_size
    type: u4
    doc: Equals the real file size.
  - id: ofs_reloc_table
    type: u4
    doc: Relocation table offset, relative to the 0x20 data base.
  - id: num_reloc
    type: u4
    doc: Number of `reloc_table` entries.
  - id: num_root
    type: u4
    doc: Number of `root_table` entries.
  - id: num_ref
    type: u4
    doc: Number of `ref_table` entries.
  - id: version
    type: str
    size: 4
    encoding: ASCII
    doc: e.g. "001B".
  - id: reserved
    size: 8
    doc: Zero-filled in every real sample seen; not read by `ScanHSD`.
  - id: data
    size: ofs_reloc_table
    doc: |
      Object-graph data section, kept as raw bytes here since its own
      internal pointers are what get walked to find any given struct in
      the first place. `root_table`/`ref_table` entries and the `_x`-typed
      instances below (`jobj`, `dobj`, `pobj`, ...) parse this same range
      again, in a separate pass, once a starting offset is known.
instances:
  reloc_table_pos:
    value: 0x20 + ofs_reloc_table
    doc: Absolute file offset of `reloc_table` (the on-disk value is 0x20-relative).
  reloc_table:
    pos: reloc_table_pos
    type: reloc_entry
    repeat: expr
    repeat-expr: num_reloc
    doc: |
      Every location in `data` that holds a pointer, so a loader can walk
      the whole set and patch each stored 0x20-relative offset into a real
      pointer in one pass, without having to trace the object graph itself
      to find them.
  root_table:
    pos: reloc_table_pos + 4 * num_reloc
    type: node_ref
    repeat: expr
    repeat-expr: num_root
    doc: |
      Named entry points into the object graph -- typically JOBJ roots for
      a model (e.g. "ToyBoxModel_TopN_joint" on a real Super Smash Bros.
      Melee item file) or other top-level structs this archive's own
      consumer looks up by name, such as "scene_data" in a Doraemon-style
      multi-archive bundle.
  ref_table:
    pos: reloc_table_pos + 4 * num_reloc + 8 * num_root
    type: node_ref
    repeat: expr
    repeat-expr: num_ref
    doc: |
      Named structs this archive expects another, externally-loaded
      archive to resolve by name -- e.g. a shared texture or animation
      referenced by several files in the same title, rather than
      duplicated into each one.
types:
  reloc_entry:
    doc: |
      One 0x20-relative offset naming a location that holds a pointer; the
      u32 stored at that location is itself a 0x20-relative offset of the
      pointed-to struct. Unlike `node_ref`, a relocation entry carries no
      name -- it is purely "patch the pointer that lives here", found by
      the loader walking every reachable field of the object graph once at
      build time and recording where each one landed.
    seq:
      - id: ofs_location
        type: u4
  node_ref:
    doc: |
      A root node or external reference: an object offset paired with its
      name-string offset. `root_table` and `ref_table` share this same
      struct; which table an entry sits in is what distinguishes "owned by
      this archive" from "expected to be supplied by another one".
    seq:
      - id: ofs_node
        type: u4
        doc: 0x20-relative offset of the referenced struct.
      - id: ofs_name
        type: u4
        doc: Offset into the string pool of this reference's NUL-terminated name.
    instances:
      as_jobj:
        pos: 0x20 + ofs_node
        type: jobj
        if: ofs_node != 0
        doc: |
          Convenience view for the common case (a JOBJ root, e.g.
          "ToyBoxModel_TopN_joint" on an item/object file). Two real
          cases are NOT a plain JOBJ here and must be read a different
          way instead: a "scene_data" root (Doraemon GC maps, some
          Kirby Air Ride/Melee menu files), whose first field is a
          NULL-terminated list of pointers to JObjDesc structs (each
          starting with ITS root JOBJ) rather than a JOBJ itself; and a
          per-fighter root (Melee character files like "PlMr.dat"),
          which is instead an FTDATA wrapper -- see `as_ftdata`. Both
          are only distinguishable from a real JOBJ by inspection (an
          empty/non-"scene_data" name, and non-finite/subnormal
          rotate/scale/translate floats, respectively) since the file
          carries no separate type tag for its root_table entries;
          lib-hsd.c's own `hsd_root_jobjs`/`hsd_walk_jobj_meshes` apply
          exactly this heuristic rather than a structural check.
      as_ftdata:
        pos: 0x20 + ofs_node
        type: ftdata
        if: ofs_node != 0
        doc: Alternate view for a per-fighter root (see `as_jobj`'s doc); `as_ftdata.skeleton` reaches the real JOBJ tree.

  vec3f:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4

  ftdata:
    doc: |
      A per-fighter root wrapper (Melee character files, e.g.
      "PlMr.dat"): everything before +0x5C is fighter-specific runtime
      data this `.ksy` does not model, and +0x5C is a pointer to the
      real skeleton root JOBJ. See `node_ref.as_jobj`'s doc for how a
      reader is expected to notice it needs this type instead of a
      plain `jobj`.
    seq:
      - id: unknown_00
        size: 0x5c
      - id: ofs_skeleton
        type: u4
    instances:
      skeleton:
        pos: 0x20 + ofs_skeleton
        type: jobj
        if: ofs_skeleton != 0

  jobj:
    doc: |
      HSD_JOBJ (0x40 bytes) -- one joint. `child`/`next` together encode
      the whole skeleton as a first-child/next-sibling tree (not a
      parent-indexed array like HSF's node table): a joint's children are
      found by following `child`, then repeatedly following that child's
      own `next` for its siblings. `rotate` is Euler radians (unlike HSF's
      degrees); `translate`/`scale`/`rotate` combine into this joint's
      local transform, composed down the `child` chain for world space.
    seq:
      - id: ofs_class_name
        type: u4
        doc: Unused here.
      - id: flags
        type: u4
      - id: ofs_child
        type: u4
      - id: ofs_next
        type: u4
        doc: Next sibling under the same parent, or 0 if this is the last.
      - id: ofs_dobj
        type: u4
        doc: Head of this joint's DOBJ (display object) chain, or 0 if this joint has no geometry.
      - id: rotate
        type: vec3f
        doc: Radians.
      - id: scale
        type: vec3f
      - id: translate
        type: vec3f
      - id: ofs_inv_world_transform
        type: u4
        doc: Unused here.
      - id: ofs_robj
        type: u4
        doc: Unused here.
    instances:
      child:
        pos: 0x20 + ofs_child
        type: jobj
        if: ofs_child != 0
      next:
        pos: 0x20 + ofs_next
        type: jobj
        if: ofs_next != 0
      dobj:
        pos: 0x20 + ofs_dobj
        type: dobj
        if: ofs_dobj != 0

  dobj:
    doc: HSD_DOBJ (0x10 bytes) -- one display object; a chain of these hangs off a JOBJ's `dobj` pointer via `next`.
    seq:
      - id: ofs_class_name
        type: u4
        doc: Unused here.
      - id: ofs_next
        type: u4
      - id: ofs_mobj
        type: u4
        doc: Material bound to every POBJ in this DOBJ's `pobj` chain.
      - id: ofs_pobj
        type: u4
        doc: Head of this display object's POBJ (polygon object) chain.
    instances:
      next:
        pos: 0x20 + ofs_next
        type: dobj
        if: ofs_next != 0
      mobj:
        pos: 0x20 + ofs_mobj
        type: mobj_desc
        if: ofs_mobj != 0
      pobj:
        pos: 0x20 + ofs_pobj
        type: pobj
        if: ofs_pobj != 0

  pobj:
    doc: |
      HSD_POBJ (0x18 bytes) -- one polygon object: an attribute-array
      pointer, a display-list buffer, and a flags-dependent union at
      +0x14 selecting how this POBJ is bound to the skeleton (see `type`
      below and each union accessor's own `doc`).
    seq:
      - id: unknown_00
        size: 4
      - id: ofs_next
        type: u4
      - id: ofs_attributes
        type: u4
        doc: Pointer to a `gx_attribute` array (NULL-name terminated) describing this POBJ's vertex format.
      - id: pobj_flags
        type: u2
      - id: dl_size_words
        type: s2
        doc: Display-list length in 32-byte units.
      - id: ofs_display_list
        type: u4
      - id: ofs_union
        type: u4
        doc: Meaning depends on `type` -- see `single_bound_jobj`, `envelope_pointers` and `shape_set`.
    instances:
      type:
        value: (pobj_flags & 0x3000) >> 12
        enum: pobj_kind
      cull_front:
        value: (pobj_flags & 0x4000) != 0
      cull_back:
        value: (pobj_flags & 0x8000) != 0
      next:
        pos: 0x20 + ofs_next
        type: pobj
        if: ofs_next != 0
      attributes:
        pos: 0x20 + ofs_attributes
        type: gx_attribute
        repeat: until
        repeat-until: _.name == gx_attr_name::null_terminator or _io.pos + 0x18 > _root._io.size
        if: ofs_attributes != 0
      display_list:
        pos: 0x20 + ofs_display_list
        size: dl_size_words * 32
        if: ofs_display_list != 0 and dl_size_words > 0
        doc: Raw GX display-list opcode stream; see the format `doc` above.
      single_bound_jobj:
        pos: 0x20 + ofs_union
        type: jobj
        if: 'ofs_union != 0 and type == pobj_kind::skin'
        doc: pobj_kind::skin -- every vertex is rigidly bound to this one JOBJ, overriding the owning DOBJ's joint.
      shape_set:
        pos: 0x20 + ofs_union
        type: shape_set_desc
        if: 'ofs_union != 0 and type == pobj_kind::shape_anim'
        doc: pobj_kind::shape_anim -- morph-target shapes for this POBJ's base mesh.
      envelope_pointers:
        pos: 0x20 + ofs_union
        type: u4
        repeat: until
        repeat-until: _ == 0 or _io.pos + 4 > _root._io.size
        if: 'ofs_union != 0 and type == pobj_kind::envelope'
        doc: |
          pobj_kind::envelope -- a NULL-terminated array of 0x20-relative
          pointers, one per unique multi-bone weight group; each points
          at a contiguous run of `envelope_desc` entries (see that type's
          `doc`) that this `.ksy` does not resolve further, since the
          array's own visible length already tells a reader where the
          per-vertex weight-group index (found via the display list's
          matrix index) should look.
  envelope_desc:
    doc: |
      HSD_EnvelopeDesc (8 bytes): one {joint, weight} pair in a multi-bone
      weight group. A group is a contiguous run of these starting at one
      of `pobj.envelope_pointers`' targets, ending at the first entry
      with `ofs_joint == 0` or `weight <= 0` (not a fixed count) -- so
      this `.ksy` exposes one entry at a time rather than an array, and a
      reader must follow `next_entry` in a loop and stop at that
      condition itself.
    seq:
      - id: ofs_joint
        type: u4
      - id: weight
        type: f4
    instances:
      joint:
        pos: 0x20 + ofs_joint
        type: jobj
        if: ofs_joint != 0

  shape_set_desc:
    doc: HSD_ShapeSetDesc (0x10 bytes).
    seq:
      - id: ofs_next
        type: u4
        doc: Unused here.
      - id: ofs_shapes
        type: u4
      - id: ofs_current_shape
        type: u4
        doc: Unused here.
      - id: num_shapes
        type: u4
    instances:
      shapes:
        pos: 0x20 + ofs_shapes
        type: shape_desc
        repeat: expr
        repeat-expr: num_shapes
        if: ofs_shapes != 0 and num_shapes > 0
        doc: Fixed-size array of `num_shapes` consecutive `shape_desc` records (not a linked chain, despite `shape_desc` also carrying its own `ofs_next`).
  shape_desc:
    doc: HSD_ShapeDesc (0x10 bytes) -- one morph-target shape's own attribute array and position-delta display list.
    seq:
      - id: ofs_next
        type: u4
        doc: Unused here; see `shape_set_desc.shapes`.
      - id: ofs_display_list
        type: u4
        doc: Position deltas from the POBJ's base mesh.
      - id: ofs_attributes
        type: u4
      - id: shape_flags
        type: u2
      - id: dl_size_words
        type: s2
    instances:
      attributes:
        pos: 0x20 + ofs_attributes
        type: gx_attribute
        repeat: until
        repeat-until: _.name == gx_attr_name::null_terminator or _io.pos + 0x18 > _root._io.size
        if: ofs_attributes != 0
      display_list:
        pos: 0x20 + ofs_display_list
        size: dl_size_words * 32
        if: ofs_display_list != 0 and dl_size_words > 0

  gx_attribute:
    doc: |
      GX_Attribute (0x18 bytes) -- one vertex attribute channel. `name`
      selects semantic (position/normal/color/texcoord/NBT); `ctype` and
      `stride` (not `component_count`, which this format leaves unused)
      give the real per-element size. The array is terminated by an entry
      whose `name` is 0xff (`GX_VA_NULL`), which is why arrays of this
      type here use `repeat-until` rather than a stored count.
    seq:
      - id: name
        type: u4
        enum: gx_attr_name
      - id: attr_type
        type: u4
        enum: gx_attr_type
        doc: DIRECT (packed inline in the display list) vs. INDEX8/INDEX16 (an index into `buffer`).
      - id: component_count
        type: u4
        doc: Unused by this decoder -- `ctype`/`stride` already give the real element size.
      - id: ctype
        type: u4
        enum: gx_comp_type
      - id: scale
        type: u1
        doc: Fixed-point shift for non-float component types.
      - id: unknown_11
        type: u1
      - id: stride
        type: s2
        doc: Bytes per element in `buffer`; 0 in DIRECT mode.
      - id: ofs_buffer
        type: u4
        doc: 0x20-relative offset of this attribute's data buffer (0 in DIRECT mode). Not modeled as a typed array here -- its real element count comes from the display list's own index stream, which this `.ksy` does not decode (see the format `doc` above).

  mobj_desc:
    doc: HSD_MObjDesc (0x18 bytes) -- one material binding.
    seq:
      - id: ofs_class_name
        type: u4
        doc: Unused here.
      - id: rendermode
        type: u4
        doc: Not decoded further -- see the format `doc` above.
      - id: ofs_texdesc
        type: u4
        doc: Head of this material's TOBJ (texture) chain.
      - id: ofs_material
        type: u4
      - id: ofs_renderdesc
        type: u4
        doc: Unused here.
      - id: ofs_pedesc
        type: u4
        doc: Not decoded further -- see the format `doc` above.
    instances:
      texdesc:
        pos: 0x20 + ofs_texdesc
        type: tobj
        if: ofs_texdesc != 0
      material:
        pos: 0x20 + ofs_material
        type: hsd_material
        if: ofs_material != 0

  hsd_material:
    doc: HSD_Material (0x14 bytes).
    seq:
      - id: ambient
        type: rgba8
      - id: diffuse
        type: rgba8
      - id: specular
        type: rgba8
      - id: alpha
        type: f4
      - id: shininess
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

  tobj:
    doc: |
      HSD_TObj (0x5C bytes) -- one texture-stage binding. A material's
      texture chain is walked via `next` starting from `mobj_desc.texdesc`.
    seq:
      - id: ofs_class_name
        type: u4
        doc: Unused here.
      - id: ofs_next
        type: u4
      - id: gx_tex_map_id
        type: u4
        doc: 0 = TEXMAP0, 1 = TEXMAP1, ...
      - id: coord
        type: u4
        doc: GX_TexGenSrc (4 = TEX0, 5 = TEX1, ...).
      - id: rotate
        type: vec3f
        doc: Radians.
      - id: scale
        type: vec3f
        doc: Z is typically 1.0.
      - id: translate
        type: vec3f
        doc: Z is typically 0.0.
      - id: wrap_s
        type: u4
        enum: gx_wrap_mode
      - id: wrap_t
        type: u4
        enum: gx_wrap_mode
      - id: repeat_s
        type: u1
      - id: repeat_t
        type: u1
      - id: unknown_3e
        size: 2
      - id: blend_flags
        type: u4
      - id: blending
        type: f4
      - id: mag_filter
        type: u4
        doc: GXTexFilter.
      - id: ofs_image
        type: u4
      - id: ofs_tlut
        type: u4
    instances:
      next:
        pos: 0x20 + ofs_next
        type: tobj
        if: ofs_next != 0
      image:
        pos: 0x20 + ofs_image
        type: hsd_image
        if: ofs_image != 0
      tlut:
        pos: 0x20 + ofs_tlut
        type: hsd_tlut
        if: ofs_tlut != 0

  hsd_image:
    doc: |
      HSD_Image (0x0C bytes). Melee stores `format_raw` as a plain GX
      texture-format enum (matching this project's own image_format_t:
      IMG_I4=0 .. IMG_CMPR=0x0e). The Wii "TV no Tomo" channel instead
      packs the real format into the high byte with a mip-level count in
      the next byte (the low two bytes are then always `0x0100`) -- a
      decoder must try both readings and let the pixel-buffer size implied
      by width/height/format pick the right one.
    seq:
      - id: ofs_pixel_data
        type: u4
      - id: width
        type: u2
      - id: height
        type: u2
      - id: format_raw
        type: u4
  hsd_tlut:
    doc: HSD_Tlut (0x10 bytes) -- an indexed texture's palette.
    seq:
      - id: ofs_palette_data
        type: u4
      - id: format
        type: u4
        enum: gx_tlut_format
        doc: 0 = IA8, 1 = RGB565, 2 = RGB5A3.
      - id: gx_tlut
        type: u4
        doc: Unused here.
      - id: num_colors
        type: u2
      - id: unknown_0e
        size: 2
enums:
  pobj_kind:
    0: skin
    1: shape_anim
    2: envelope
  gx_attr_name:
    9: pos
    10: nrm
    11: clr0
    12: clr1
    13: tex0
    14: tex1
    15: tex2
    16: tex3
    17: tex4
    18: tex5
    19: tex6
    20: tex7
    25: nbt
    0xff: null_terminator
  gx_attr_type:
    0: none
    1: direct
    2: index8
    3: index16
  gx_comp_type:
    0: u8
    1: s8
    2: u16
    3: s16
    4: f32
  gx_wrap_mode:
    0: clamp
    1: repeat
    2: mirror
  gx_tlut_format:
    0: ia8
    1: rgb565
    2: rgb5a3
