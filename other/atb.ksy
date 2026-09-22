meta:
  id: atb
  file-extension: atb
  endian: be
  title: Nintendo/Camelot ATB 2D sprite atlas
doc: |
  A flat 2D sprite/animation container: banks of animation frames,
  patterns made of layered textured quads, and the textures themselves
  (palette + image data). All tables are located by absolute offsets
  from a 20-byte header. The four 16-bit counts occupy bytes 0..7;
  the three 32-bit table offsets begin immediately at byte 8. There is
  no reserved header word between them.

  There is no magic. nintoolbox identifies ATB structurally: bank count
  at most 4096, pattern count at most 8192, texture count at most 2048,
  and at least one of those three counts nonzero. A used table must fit
  entirely and begin at or after byte 20; unused-table offsets may be
  zero or another in-file offset. Every bank's frame table and pattern's
  layer table must fit. Texture format must be at most 0x0c, width and
  height at most 4096, and all declared palette/image byte ranges must
  fit. The fourth count, num_references, is retained but not used to
  locate any table by this reader.

  The writer lays out patterns and their layers first, then banks and
  their frames, then texture descriptors. It pads to a 32-byte boundary
  with 0x88 bytes before writing palettes and images; descriptor offsets
  are patched to those absolute positions. It writes the bank/pattern
  reserved halfwords as zero. These are writer conventions, not extra
  detector requirements. Frame durations and flip fields are preserved
  as signed values without interpreting their units or bit meanings.
seq:
  - id: num_banks
    type: u2
    doc: Count of eight-byte bank descriptors.
  - id: num_patterns
    type: u2
    doc: Count of 16-byte pattern descriptors.
  - id: num_textures
    type: u2
    doc: Count of 20-byte texture descriptors.
  - id: num_references
    type: u2
    doc: Reference count retained by the reader; no separate table is parsed.
  - id: ofs_banks
    type: u4
    doc: Absolute byte offset of the bank descriptor table.
  - id: ofs_patterns
    type: u4
    doc: Absolute byte offset of the pattern descriptor table.
  - id: ofs_textures
    type: u4
    doc: Absolute byte offset of the texture descriptor table.
instances:
  banks:
    io: _root._io
    pos: ofs_banks
    type: bank
    repeat: expr
    repeat-expr: num_banks
    if: num_banks > 0
  patterns:
    io: _root._io
    pos: ofs_patterns
    type: pattern
    repeat: expr
    repeat-expr: num_patterns
    if: num_patterns > 0
  textures:
    io: _root._io
    pos: ofs_textures
    type: texture
    repeat: expr
    repeat-expr: num_textures
    if: num_textures > 0
types:
  bank:
    seq:
      - id: num_frames
        type: u2
        doc: Number of 12-byte frame records for this bank.
      - id: reserved
        size: 2
      - id: ofs_frames
        type: u4
        doc: Absolute byte offset of this bank's frame records.
    instances:
      frames:
        io: _root._io
        pos: ofs_frames
        type: anim_frame
        repeat: expr
        repeat-expr: num_frames
        if: num_frames > 0
  anim_frame:
    seq:
      - id: pattern_index
        type: s2
      - id: frame_length
        type: s2
        doc: Signed frame duration value; unit not established by the scanner.
      - id: shift_x
        type: s2
      - id: shift_y
        type: s2
      - id: flip
        type: s2
        doc: Signed flip value; bit interpretation is not established here.
      - id: unknown
        type: s2
  pattern:
    seq:
      - id: num_layers
        type: u2
        doc: Number of 32-byte textured-quad layer records.
      - id: center_x
        type: s2
      - id: center_y
        type: s2
      - id: width
        type: s2
      - id: height
        type: s2
      - id: reserved
        size: 2
      - id: ofs_layers
        type: u4
        doc: Absolute byte offset of this pattern's layer records.
    instances:
      layers:
        io: _root._io
        pos: ofs_layers
        type: layer
        repeat: expr
        repeat-expr: num_layers
        if: num_layers > 0
  layer:
    seq:
      - id: alpha
        type: u1
        doc: Per-layer opacity byte.
      - id: flip
        type: u1
        doc: Per-layer flip byte; exact bit assignment is not decoded here.
      - id: texture_index
        type: s2
        doc: Signed index into the texture descriptor table.
      - id: tex_coord_tl_x
        type: s2
      - id: tex_coord_tl_y
        type: s2
      - id: tex_coord_w
        type: s2
      - id: tex_coord_h
        type: s2
      - id: shift_x
        type: s2
      - id: shift_y
        type: s2
      - id: vtx_tl_x
        type: s2
      - id: vtx_tl_y
        type: s2
      - id: vtx_tr_x
        type: s2
      - id: vtx_tr_y
        type: s2
      - id: vtx_br_x
        type: s2
      - id: vtx_br_y
        type: s2
      - id: vtx_bl_x
        type: s2
      - id: vtx_bl_y
        type: s2
  texture:
    seq:
      - id: bpp
        type: u1
        doc: Texture bit-depth value carried through by the reader and writer.
      - id: format
        type: u1
        doc: 0-0x0c.
      - id: palette_size
        type: u2
        doc: Number of 16-bit palette entries.
      - id: width
        type: u2
      - id: height
        type: u2
      - id: len_image
        type: u4
        doc: Image payload byte length.
      - id: ofs_palette
        type: u4
        doc: Absolute palette byte offset; relevant when palette_size is nonzero.
      - id: ofs_image
        type: u4
        doc: Absolute image byte offset.
    instances:
      palette_data:
        io: _root._io
        pos: ofs_palette
        size: palette_size * 2
        if: palette_size > 0
      image_data:
        io: _root._io
        pos: ofs_image
        size: len_image
        if: len_image > 0
