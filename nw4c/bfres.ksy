meta:
  id: bfres
  file-extension: bfres
  endian: be
  title: Wii U BFRES resource container
doc: |
  Nintendo's Wii U-generation "FRES" resource container -- the platform's
  successor to BRRES, holding a game's models, textures and animations.
  Only the Wii U flavour (version 3.x, big-endian) is described here: the
  Switch reuses the exact same `FRES` magic for an unrelated,
  little-endian container with its own layout and a separate BNTX for
  textures, and is out of scope.

  BFRES belongs to NW4F (NintendoWare for Cafe -- "Cafe" being the Wii
  U's own SDK codename), not to NW4C (NintendoWare for CTR, the 3DS
  lineage that produced BCH/BFLYT/BFLAN/BFLIM/CWAV). The two are related
  sibling generations of the same middleware family rather than one SDK
  wearing two names: NW4C shipped for the 3DS, NW4F for the Wii U, and
  each has its own model container (BCH vs. BFRES) even though the 2D
  layout/animation/font tooling (BFLYT/BFLAN/BFLIM) and the wave-sample
  container (`bxwav.ksy`'s FWAV/CWAV pair) were shared or paralleled
  across both. This repository lumps every 3DS- and Wii U-originated
  post-NW4R format into one `nw4c/` folder for convenience; it is not a
  claim that BFRES or `gtx.ksy`'s GTX are themselves NW4C formats.

  Unlike BRRES, whose resource-group offsets are relative to the group
  that holds them, and BCH, whose offsets are relative to the main
  header, BFRES is **self-relative**: every pointer field's value is added
  to that field's *own* file offset, not to any shared base. This
  definition threads each type's own file position through as a `base`
  parameter so every pointer inside it can resolve `base + <static field
  offset> + <stored delta>` without re-deriving it.

  Geometry lives in `FMDL -> FVTX` (vertex buffers, GX2 attributes with
  their own per-attribute numeric format and a byte offset/stride into a
  shared interleaved buffer) and `FMDL -> FSHP` (shapes, each carrying one
  LOD model with a triangle-list index buffer). This definition follows
  that chain down to the raw vertex/index buffer bytes and stops there --
  turning a GX2 attribute format code into a decoded float is a separate
  kind of work from describing the container, exactly where `bch.ksy`
  draws the same line for PICA200.

  The reference implementation is `ParseBFRES()` in this project's sibling
  repo, `wiimms-szs-tools-nintendo/project/src/lib-bfres.c`; that C code
  only ever follows the *first* model-group entry after its sentinel and
  the *first* FVTX/FSHP indices it needs, so only those fields are
  something the C side has independently proven correct. The header
  fields between `len_file` and the model-group pointer (`0x10`-`0x1f`)
  and the eleven index-group pointer slots after it (`0x24`-`0x4f`,
  publicly documented elsewhere as FTEX/FSKA/FSHU/FTXP/FVIS/FSCN and
  friends) are read by nothing in that C parser, so they are left as
  plain reserved bytes here rather than guessed at -- this repo's
  convention is to describe what has actually been checked against real
  bytes, not what other tooling's docs claim.

  Verified against two real samples:

  * **`SPL_box_duck.bfres`** (Splatoon, zlib-wrapped -- decompress before
    feeding this definition the raw `FRES`): `bom` reads `0xfeff`,
    `len_file` (`0x0c`) matches the decompressed size (835,584 bytes)
    exactly, the model group holds one entry named `SPL_box_duck` whose
    body is a real `FMDL`, that model's ten `FVTX`s and ten `FSHP`s match
    `num_fvtx`/`num_fshp`, the first `FVTX` is 124 vertices across five
    attributes (`_p0` 16_16_16_16 float, `_n0`/`_t0`/`_b0` 10_10_10_2 /
    8_8_8_8 snorm, `_u0` 16_16 unorm) sharing one interleaved 24-byte-
    stride buffer, and the first `FSHP` (`duck_hober__SPL_box_duck_00_MAT`)
    resolves a triangle-list LOD (`prim` 4) with a 480-entry, 16-bit index
    buffer whose byte size (960) is exactly `480 * 2`.
  * **`gsys.bfres`** (Wii U System Settings title, `HATE01`, ~67 MB,
    uncompressed): confirms the header fields on a second, unrelated
    title -- `bom` `0xfeff`, `version_major` `3`, `len_file` matching the
    real 67,977,216-byte file exactly. `num_models` reads `0` here (this
    resource pack is TV-configuration UI art, not a 3D model), which is
    itself a useful data point: `model_group`'s `if: num_models > 0`
    guard means this definition parses a real *model-less* Wii U BFRES
    cleanly rather than dereferencing a group that was never written.
seq:
  - id: magic
    contents: "FRES"
  - id: version_major
    type: u1
    doc: |
      `3` on both Wii U samples checked. `ParseBFRES()` rejects anything
      else, since a Switch BFRES (version 9+) reuses this same magic.
  - id: version_minor
    type: u1
  - id: version_micro
    type: u1
  - id: version_revision
    type: u1
  - id: bom
    type: u2
    doc: |
      `0xfeff` on every Wii U sample; `ParseBFRES()` requires exactly
      this. A Switch BFRES has `0x0000` here and its real byte-order mark
      four bytes later instead -- a different layout, not a flag on this
      one.
  - id: unknown_0a
    type: u2
  - id: len_file
    type: u4
    doc: Total file size. Matches the real (decompressed) file length on both samples.
  - id: reserved_10
    size: 0x10
    doc: |
      `0x10`-`0x1f`. Not read by `ParseBFRES()`; left undescribed rather
      than guessed. Likely candidates from the format's general shape
      (alignment, string-table offset/length, relocation info) are not
      asserted here because nothing in this codebase's ground truth
      confirms them.
  - id: ofs_model_group
    type: s4
    doc: |
      Self-relative delta to the FMDL index group (see `model_group`).
      This field sits at file offset `0x20`, which is exactly what
      `ParseBFRES()` reads as `REL(d,0x20)`.
  - id: reserved_group_ptrs
    type: u4
    repeat: expr
    repeat-expr: 11
    doc: |
      `0x24`-`0x4f`: eleven more self-relative index-group pointers
      (textures, skeletal/material/bone-visibility/scene animations,
      embedded and external files, by published BFRES documentation's
      ordering) that `ParseBFRES()` never follows. Left as raw words for
      the same reason as `reserved_10`.
  - id: num_models
    type: u2
    doc: |
      Entry count of the FMDL group. This field sits at file offset
      `0x50`, exactly what `ParseBFRES()` reads as `rb16(d+0x50)`.
  - id: reserved_52
    size: 0x16
    doc: |
      `0x52`-`0x67`: presumably one count per the eleven group pointers
      above, by analogy with `num_models` -- not confirmed here.
instances:
  model_group_addr:
    value: 0x20 + ofs_model_group
  model_group:
    pos: model_group_addr
    type: fres_group(model_group_addr, true)
    if: num_models > 0
types:
  # The same radix-tree dictionary idea as BRRES's resource_group, but
  # every entry's ofs_name/ofs_data is self-relative to *that field*
  # rather than to the group's base offset.
  fres_group:
    params:
      - id: base
        type: u4
      - id: is_model_group
        type: bool
        doc: |
          Selects what an entry's data pointer resolves to: `fmdl` for the
          model group, `fshp` for a shape group. BFRES has no on-disk tag
          distinguishing group kinds -- the caller already knows which
          group it asked for, same as `ParseBFRES()` does.
    seq:
      - id: len_group
        type: u4
      - id: num_entries
        type: u4
      - id: entries
        type: fres_entry(_io.pos, is_model_group)
        repeat: expr
        repeat-expr: num_entries + 1
        doc: Entry 0 is a sentinel root node, exactly like BRRES's resource_group.

  fres_entry:
    params:
      - id: base
        type: u4
        doc: This entry's own absolute file offset (16 bytes, fixed stride).
      - id: is_model_group
        type: bool
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
      name_addr:
        value: base + 8 + ofs_name
      data_addr:
        value: base + 12 + ofs_data
      name:
        pos: name_addr
        io: _root._io
        type: strz
        encoding: ASCII
        if: ofs_name != 0
      fmdl:
        pos: data_addr
        io: _root._io
        type: fmdl(data_addr)
        if: ofs_data != 0 and is_model_group
      fshp:
        pos: data_addr
        io: _root._io
        type: fshp(data_addr)
        if: ofs_data != 0 and not is_model_group

  fmdl:
    params:
      - id: base
        type: u4
    seq:
      - id: magic
        contents: "FMDL"
      - id: ofs_name
        type: s4
      - id: reserved_08
        size: 8
      - id: ofs_fvtx_array
        type: s4
        doc: Self-relative to file offset `base + 0x10`; `FVTX`s are packed here at a fixed 0x20-byte stride.
      - id: ofs_fshp_group
        type: s4
        doc: Self-relative to file offset `base + 0x14`; a `fres_group` of `FSHP` shapes.
      - id: reserved_18
        size: 8
      - id: num_fvtx
        type: u2
      - id: num_fshp
        type: u2
    instances:
      name_addr:
        value: base + 4 + ofs_name
      name:
        pos: name_addr
        io: _root._io
        type: strz
        encoding: ASCII
        if: ofs_name != 0
      fvtx_array_addr:
        value: base + 0x10 + ofs_fvtx_array
      fshp_group_addr:
        value: base + 0x14 + ofs_fshp_group
      fvtx:
        pos: fvtx_array_addr
        io: _root._io
        type: fvtx(fvtx_array_addr)
        if: num_fvtx > 0
        doc: The first FVTX only; further ones sit at `fvtx_array_addr + i*0x20`.
      fshp_group:
        pos: fshp_group_addr
        io: _root._io
        type: fres_group(fshp_group_addr, false)
        if: num_fshp > 0

  fvtx:
    params:
      - id: base
        type: u4
    seq:
      - id: magic
        contents: "FVTX"
      - id: num_attr
        type: u1
      - id: num_buf
        type: u1
      - id: reserved_06
        size: 2
      - id: count
        type: u4
        doc: Vertex count.
      - id: reserved_0c
        size: 4
      - id: ofs_attrs
        type: s4
        doc: Self-relative to file offset `base + 0x10`; an array of `num_attr` 12-byte attribute records.
      - id: reserved_14
        size: 4
      - id: ofs_bufs
        type: s4
        doc: Self-relative to file offset `base + 0x18`; an array of `num_buf` buffer_info records.
      - id: reserved_1c
        size: 4
    instances:
      attrs_addr:
        value: base + 0x10 + ofs_attrs
      bufs_addr:
        value: base + 0x18 + ofs_bufs
      attrs:
        pos: attrs_addr
        io: _root._io
        type: fvtx_attr(_io.pos)
        repeat: expr
        repeat-expr: num_attr
      bufs:
        pos: bufs_addr
        io: _root._io
        type: buffer_info(_io.pos)
        repeat: expr
        repeat-expr: num_buf

  fvtx_attr:
    params:
      - id: base
        type: u4
        doc: This attribute record's own absolute file offset (12 bytes, fixed stride).
    seq:
      - id: ofs_name
        type: s4
      - id: buffer_index
        type: u1
        doc: Which of the FVTX's buffer_info entries this attribute's data lives in.
      - id: reserved_05
        type: u1
      - id: buffer_offset
        type: u2
        doc: Byte offset of this attribute within one interleaved vertex record.
      - id: format
        type: u4
        enum: gx2_attrib_format
        doc: GX2 vertex attribute format code (not decoded here -- see the doc block).
    instances:
      name_addr:
        value: base + ofs_name
      name:
        pos: name_addr
        io: _root._io
        type: strz
        encoding: ASCII
        if: ofs_name != 0
        doc: |
          Follows the `_p0`/`_n0`/`_t0`/`_b0`/`_u0` (position/normal/
          tangent/binormal/UV) naming convention `ParseBFRES()` matches on
          by prefix.
    enums:
      gx2_attrib_format:
        0x00000007: unorm_16_16
        0x00000207: snorm_16_16
        0x0000000a: unorm_8_8_8_8
        0x0000020a: snorm_8_8_8_8
        0x0000020b: snorm_10_10_10_2
        0x0000080d: float_16_16
        0x0000080f: float_16_16_16_16
        0x00000806: float_32_32
        0x00000811: float_32_32_32
        0x00000813: float_32_32_32_32

  buffer_info:
    doc: |
      Shared shape for both an FVTX's vertex buffers and an LOD model's
      index buffer -- `ParseBFRES()` reads both with the identical
      `size @ +4` / `stride @ +0xc` / `ofs_data @ +0x14` offsets.
    params:
      - id: base
        type: u4
        doc: |
          This record's own absolute file offset. Passed explicitly
          rather than derived from `_io.pos` at the time `data_addr` is
          read, since that instance can be (and in practice is)
          evaluated long after construction, once the shared stream
          cursor has moved on to other objects -- an earlier version of
          this definition computed a wrong `data_addr` from a stale
          `_io.pos` for exactly that reason.
    seq:
      - id: reserved_00
        size: 4
      - id: len_data
        type: u4
      - id: reserved_08
        size: 4
      - id: stride
        type: u2
        doc: Bytes per record. Zero on an index buffer, where indices are packed instead.
      - id: reserved_0e
        size: 6
      - id: ofs_data
        type: s4
    instances:
      data_addr:
        value: base + 0x14 + ofs_data
      data:
        pos: data_addr
        io: _root._io
        size: len_data
        if: len_data > 0

  fshp:
    params:
      - id: base
        type: u4
    seq:
      - id: magic
        contents: "FSHP"
      - id: ofs_name
        type: s4
      - id: reserved_08
        size: 10
      - id: vtx_index
        type: u2
        doc: Index into the owning FMDL's FVTX array.
      - id: reserved_14
        size: 16
      - id: ofs_lod
        type: s4
        doc: Self-relative to file offset `base + 0x24`; the first LOD model.
    instances:
      name_addr:
        value: base + 4 + ofs_name
      name:
        pos: name_addr
        io: _root._io
        type: strz
        encoding: ASCII
        if: ofs_name != 0
      lod_addr:
        value: base + 0x24 + ofs_lod
      lod:
        pos: lod_addr
        io: _root._io
        type: lod_model(lod_addr)

  lod_model:
    params:
      - id: base
        type: u4
    seq:
      - id: primitive_type
        type: u4
        doc: "4 = triangle list, the only kind `ParseBFRES()` accepts."
      - id: index_format
        type: u4
        doc: "4 = 16-bit indices, 9 = 32-bit indices."
      - id: index_count
        type: u4
      - id: reserved_0c
        size: 8
      - id: ofs_index_buffer
        type: s4
        doc: Self-relative to file offset `base + 0x14`; a buffer_info for the index data.
    instances:
      index_buffer_addr:
        value: base + 0x14 + ofs_index_buffer
      index_buffer:
        pos: index_buffer_addr
        io: _root._io
        type: buffer_info(index_buffer_addr)
