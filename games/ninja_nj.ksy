meta:
  id: ninja_nj
  title: Sega "Ninja" chunk model family, Wii port (.nj / .njm / Models.dat)
  file-extension: nj
  endian: be
doc: |
  Wii port of Sega's Dreamcast-era "Ninja" chunk formats (NJTL texture
  list, NJCM chunk model, NMDM chunk motion), as shipped by Sonic Team's
  Illvelo (.nj / .njm; 962 + 367 samples on the retail JP disc) and Milestone
  (Chaos Field / Karous `*Models.dat` model banks; all 156 models of the
  Ultimate Shooting Collection verified).

  The port makes two systematic changes: every 4-byte chunk tag is the
  *reverse* of its usual ASCII spelling (`NJTL` -> `LTJN`, `NJCM` -> `MCJN`,
  `NMDM` -> `MDMN`, `NCAM` -> `MACN`, and Nintendo's `POF0` pointer-fixup tag
  -> `0FOP`), and every multi-byte number is big-endian.

  A file is a flat run of `(tag, size, body)` chunks. Only NJTL and NJCM are
  described here; NMDM motions and unknown tags are opaque.

  NJCM body = `njs_object` tree (all pointers body-relative):
  `{u4 evalflags, u4 model, f4 pos[3], s4 ang[3] (BAMS, 0x10000 = 360 deg),
  f4 scale[3], u4 child, u4 sibling}`; flags 1/2/4 = no pos/rot/scale, 8 =
  hidden, 0x10 = skip children, 0x20 = ZXY rotation order. A model is
  `{u4 vlist, u4 plist, f4 center[3], f4 radius}`.
  vlist = `{u2 type, u2 size_words, u4 count, vertices}`; type `0x8023` is
  `{f4 xyz, u1 rgba[4]}` (16 bytes), `0x802a` is `{f4 xyz, f4 normal[3],
  u1 rgba[4]}` (28 bytes). plist = chunks of u2 words: `0x2513`
  `{u2 size, diffuse argb, ambient argb}`, `0x3408` strips (below) and
  `0x00ff` = end; UVs are 10-bit fixed point (1/1024).
seq:
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: tag
        type: str
        size: 4
        encoding: ASCII
        doc: Reversed tag (`LTJN`, `MCJN`, `MDMN`, `MACN`, `0FOP`).
      - id: size
        type: u4
      - id: body
        size: size
        type:
          switch-on: tag
          cases:
            '"LTJN"': texture_list
            '"MCJN"': object_body
  texture_list:
    seq:
      - id: texlist_offset
        type: u4
        doc: Body-relative offset of the entry array.
      - id: tex_count
        type: u4
    instances:
      entries:
        pos: texlist_offset
        type: texture_entry
        repeat: expr
        repeat-expr: tex_count
  texture_entry:
    seq:
      - id: name_offset
        type: u4
        doc: Body-relative offset of a NUL-terminated ASCII texture name.
      - id: global_index
        type: u4
      - id: flags
        type: u4
    instances:
      name:
        pos: name_offset
        type: strz
        encoding: ASCII
        io: _parent._io
  object_body:
    instances:
      root:
        pos: 0
        type: njs_object
  njs_object:
    seq:
      - id: eval_flags
        type: u4
      - id: model_ptr
        type: u4
      - id: pos
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: ang
        type: s4
        repeat: expr
        repeat-expr: 3
        doc: BAMS; 0x10000 = 360 degrees.
      - id: scale
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: child_ptr
        type: u4
      - id: sibling_ptr
        type: u4
    instances:
      model:
        pos: model_ptr
        type: model
        if: model_ptr != 0
      child:
        pos: child_ptr
        type: njs_object
        if: child_ptr != 0
      sibling:
        pos: sibling_ptr
        type: njs_object
        if: sibling_ptr != 0
  model:
    seq:
      - id: vlist_ptr
        type: u4
      - id: plist_ptr
        type: u4
      - id: center
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: radius
        type: f4
    instances:
      vlist:
        pos: vlist_ptr
        type: vertex_list
        if: vlist_ptr != 0
      plist:
        pos: plist_ptr
        type: polygon_list
        if: plist_ptr != 0
  vertex_list:
    seq:
      - id: type
        type: u2
        enum: vertex_type
      - id: size_words
        type: u2
      - id: count
        type: u4
      - id: vertices
        type:
          switch-on: type
          cases:
            'vertex_type::position_color': vertex_pc
            'vertex_type::position_normal_color': vertex_pnc
        repeat: expr
        repeat-expr: count
  vertex_pc:
    seq:
      - id: position
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: rgba
        size: 4
  vertex_pnc:
    seq:
      - id: position
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: normal
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: rgba
        size: 4
  polygon_list:
    seq:
      - id: chunks
        type: poly_chunk
        repeat: until
        repeat-until: _.id == 0x00ff
  poly_chunk:
    seq:
      - id: id
        type: u2
      - id: body
        type:
          switch-on: id
          cases:
            0x2513: material_chunk
            0x3408: strip_chunk
  material_chunk:
    seq:
      - id: size_words
        type: u2
      - id: colors
        size: size_words * 2
        doc: Diffuse ARGB then ambient ARGB.
  strip_chunk:
    seq:
      - id: texture_word
        type: u2
        doc: '`0x4000 | texture_index`.'
      - id: render_flags
        type: u2
      - id: size_words
        type: u2
      - id: strip_count
        type: u2
      - id: strips
        type: strip
        repeat: expr
        repeat-expr: strip_count
  strip:
    seq:
      - id: length
        type: s2
        doc: Negative = reversed winding.
      - id: vertices
        type: strip_vertex
        repeat: expr
        repeat-expr: 'length < 0 ? -length : length'
  strip_vertex:
    seq:
      - id: index
        type: u2
      - id: u
        type: u2
        doc: 10-bit fixed point (1/1024).
      - id: v
        type: u2
        doc: 10-bit fixed point (1/1024).
enums:
  vertex_type:
    0x8023: position_color
    0x802a: position_normal_color
