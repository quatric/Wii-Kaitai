meta:
  id: atb
  file-extension: atb
  endian: be
  title: Nintendo/Camelot ATB 2D sprite atlas
doc: |
  A flat 2D sprite/animation container: banks of animation frames,
  patterns made of layered textured quads, and the textures themselves
  (palette + image data). All tables are located by absolute offsets
  from a 20-byte header; an unused table's count is 0 and its offset is
  either 0 or another in-file offset (never validated further).
seq:
  - id: num_banks
    type: u2
  - id: num_patterns
    type: u2
  - id: num_textures
    type: u2
  - id: num_references
    type: u2
  - id: reserved
    size: 2
  - id: ofs_banks
    type: u4
  - id: ofs_patterns
    type: u4
  - id: ofs_textures
    type: u4
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
      - id: reserved
        size: 2
      - id: ofs_frames
        type: u4
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
      - id: shift_x
        type: s2
      - id: shift_y
        type: s2
      - id: flip
        type: s2
      - id: unknown
        type: s2
  pattern:
    seq:
      - id: num_layers
        type: u2
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
      - id: flip
        type: u1
      - id: texture_index
        type: s2
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
      - id: ofs_palette
        type: u4
      - id: ofs_image
        type: u4
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
