meta:
  id: mkw_kcl
  file-extension: kcl
  application: Mario Kart Wii and other Nintendo EAD racing titles (KCL collision data)
  endian: be
doc: |
  Nintendo EAD's KCL collision-mesh format, as parsed by `lib-kcl.c`/
  `lib-kcl.h` and `lib-kcl-v2.c` of Wiimms SZS Tools. Used for track/object
  collision in Mario Kart Wii and related EAD titles.

  Every triangle ("prism") is stored pre-computed for a specific
  point-in-triangle test rather than as 3 raw vertices: a base vertex, 4
  normals (face + 3 edge normals) and a length, all indexing shared
  position/normal pools; a spatial-index "octree" then maps world-space
  cube cells to lists of candidate prism indices for fast lookup. See
  `KCL_V_*` in `lib-kcl.h` for the version matrix.

  Two file generations exist, both handled by the *same* reader/writer in
  the source (this is why `kcl-v2` is folded into this single definition
  rather than given its own `.ksy`):

    * **V1** (`kcl_head_t`, this definition's `header_v1`): a single
      model per file. Three sub-variants differ only in header size and
      value encoding: GC (56-byte header, no sphere `radius` field),
      Wii/3DS (60-byte header, `float32` geometry) and DS (60-byte
      header, but positions/length are 32.32 fixed point and normals are
      16.16 fixed point, scaled by `KCL_DS_FXSCALE` = 4096.0). Triangle
      index lists in the octree leaves are 1-based and 0-terminated.
      Byte order is normally big-endian except for DS/3DS (little-endian),
      but the source accepts either order for any variant on read.

    * **V2** (`kcl_v2_head_t`, this definition's `header_v2`, handled by
      `ScanRawKCL_V2()`/`CreateRawKCL_V2()` in `lib-kcl-v2.c`): introduced
      for Wii U/Switch titles. Identified by the fixed 32-bit magic
      `0x02020000` (always big-endian, even in an otherwise
      little-endian V2 file). Adds support for *multiple* models per
      file via a top-level model-offset array and a global octree that
      selects a model before that model's own local octree is walked.
      Its 20-byte prism records (`kcl_prism_v2_t`) are `kcl_triangle_t`
      plus a `global_index` field; leaf triangle lists are 0-based and
      terminated by `0xffff` instead of `0`.

  The octree itself (a hierarchy of `mask`/`coord_rshift`/`y_lshift`/
  `z_lshift`-addressed cubes bottoming out in leaf triangle-index lists)
  has no fixed record size -- its shape depends on the spatial
  subdivision chosen at build time -- so it is not decoded field-by-field
  here; `sect_off[3]` / `octree_off` locate it and it is exposed as raw
  bytes for a dedicated octree walker.
seq:
  - id: version_probe
    type: u4
    doc: |
      Peek at the first 4 bytes to distinguish V2 (`KCL_V2_MAGIC` =
      0x02020000, always big-endian) from V1 (whose first field is
      `sect_off[0]`, a small file-relative offset -- never equal to the
      V2 magic in practice).
  - id: header_v1
    type: header_v1
    if: version_probe != 0x02020000
  - id: header_v2
    type: header_v2
    if: version_probe == 0x02020000
types:
  header_v1:
    doc: |
      V1 file/model header (`kcl_head_t` / `kcl_model_head_t`). 60 bytes
      for GameCube/Wii/3DS/DS; GameCube historically omits the trailing
      `radius` field (56 bytes) but this definition always reads the full
      60-byte form, matching the Wii/3DS layout used by Mario Kart Wii.
    seq:
      - id: sect_off
        type: u4
        repeat: expr
        repeat-expr: 4
        doc: File-relative offsets of positions, normals, prisms and octree.
      - id: thickness
        type: f4
        doc: Prism thickness, used by the point-in-triangle test.
      - id: min
        type: f4
        repeat: expr
        repeat-expr: 3
        doc: Minimum coordinate of the octree's bounding volume.
      - id: mask
        type: u4
        repeat: expr
        repeat-expr: 3
        doc: Coordinate masks for octree addressing.
      - id: coord_rshift
        type: u4
        doc: Right shift applied to all coordinates before octree lookup.
      - id: y_lshift
        type: u4
        doc: Left shift applied to the Y octree index.
      - id: z_lshift
        type: u4
        doc: Left shift applied to the Z octree index.
      - id: radius
        type: f4
        doc: Sphere radius used for broad-phase culling (absent in the 56-byte GC header).
    instances:
      # sect_off[0]/[1] (positions/normals pools) are flat, tightly packed
      # f32x3 arrays with no explicit element count anywhere in the header;
      # the source derives the usable range from the triangle pool's own
      # vertex/normal indices, so they are not exposed as a fixed-length
      # array here -- read them via 'sect_off[0]'/'sect_off[1]' directly.
      triangles:
        io: _root._io
        pos: sect_off[2]
        type: triangle_v1
        repeat: expr
        repeat-expr: (sect_off[3] - sect_off[2]) / 0x10
        doc: Triangle pool; bounded by the octree's start offset (`sect_off[3]`).
      octree:
        io: _root._io
        pos: sect_off[3]
        size-eos: true
        doc: |
          Spatial index; variable-shape cube hierarchy bottoming out in
          1-based, 0-terminated `u16` triangle-index leaf lists. Not
          decoded here -- see class doc.

  triangle_v1:
    doc: kcl_triangle_t -- one collision triangle ("prism"), V1 layout.
    seq:
      - id: length
        type: f4
      - id: idx_vertex
        type: u2
      - id: idx_normal
        type: u2
        repeat: expr
        repeat-expr: 4
        doc: Face normal followed by the 3 edge normals.
      - id: flag
        type: u2
        doc: KCL collision flag; low bits select the terrain "type", see games' kcl.inc tables.

  header_v2:
    doc: |
      V2 file header (`kcl_v2_head_t`). Unlike V1, this is strictly a
      *file* header: it never repeats per model. `version` is always
      big-endian even in an otherwise little-endian file; every other
      field uses the file's own byte order.
    seq:
      - id: version
        type: u4
        doc: Always `KCL_V2_MAGIC` = 0x02020000.
      - id: octree_off
        type: u4
        doc: Absolute file offset of the top-level model-selection octree.
      - id: modelarr_off
        type: u4
        doc: Absolute file offset of the model offset array.
      - id: model_count
        type: u4
      - id: min
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: max
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: shift
        type: u4
        repeat: expr
        repeat-expr: 3
      - id: prism_count
        type: u4
        doc: Total number of prisms across all models.
    instances:
      model_offsets:
        io: _root._io
        pos: modelarr_off
        type: u4
        repeat: expr
        repeat-expr: model_count
      octree:
        io: _root._io
        pos: octree_off
        size-eos: true
        doc: Top-level model-selection octree; not decoded here -- see class doc.

  model_v2:
    doc: |
      Per-model header inside a V2 file (`kcl_model_head_t`, same layout
      as V1's but with true absolute `sect_off` values instead of V1's
      "offset - 0x10" convention).
    seq:
      - id: sect_off
        type: u4
        repeat: expr
        repeat-expr: 4
      - id: thickness
        type: f4
      - id: min
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: mask
        type: u4
        repeat: expr
        repeat-expr: 3
      - id: coord_rshift
        type: u4
      - id: y_lshift
        type: u4
      - id: z_lshift
        type: u4
      - id: radius
        type: f4
    instances:
      triangles:
        io: _root._io
        pos: sect_off[2]
        type: triangle_v2
        repeat: eos
      octree:
        io: _root._io
        pos: sect_off[3]
        size-eos: true

  triangle_v2:
    doc: |
      kcl_prism_v2_t -- one collision triangle in a V2 model: identical
      to `triangle_v1` plus a global (file-wide) triangle index. Leaf
      lists referencing this array are 0-based and `0xffff`-terminated
      (V1 lists are 1-based and 0-terminated).
    seq:
      - id: length
        type: f4
      - id: idx_vertex
        type: u2
      - id: idx_normal
        type: u2
        repeat: expr
        repeat-expr: 4
      - id: flag
        type: u2
      - id: global_index
        type: u4
