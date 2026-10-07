meta:
  id: castlevania_spr
  title: Konami Castlevania DS sprite object (so/p_*.dat)
  file-extension: dat
  endian: le
doc: |
  Konami's Nintendo DS Castlevania sprite object definition (Dawn of
  Sorrow, Portrait of Ruin, Order of Ecclesia; 512 of 512 retail files
  verified). Characters, enemies and bosses are animated through these
  containers, magic `0xBEEFF00D` (bytes `0D F0 EF BE`).

  Tables are located by header offsets: parts (16 bytes), hitboxes (8),
  frames (12), frame delays (8) and animations (8). A frame's
  `first_part_offset` / `first_hitbox_offset` are byte offsets *relative to* the
  parts / hitboxes tables.
seq:
  - id: magic
    contents: [0x0d, 0xf0, 0xef, 0xbe]
  - id: part_list_offset
    type: u4
  - id: hitbox_list_offset
    type: u4
  - id: frame_list_offset
    type: u4
  - id: frame_delay_list_offset
    type: u4
  - id: anim_list_offset
    type: u4
  - id: unused_18
    type: u4
  - id: unused_1c
    type: u4
  - id: footer_offset
    type: u4
  - id: num_frames
    type: u4
  - id: num_anims
    type: u4
  - id: file_size
    type: u4
instances:
  frames:
    pos: frame_list_offset
    type: frame
    repeat: expr
    repeat-expr: num_frames
  anims:
    pos: anim_list_offset
    type: anim
    repeat: expr
    repeat-expr: num_anims
types:
  part:
    seq:
      - id: x_pos
        type: s2
      - id: y_pos
        type: s2
      - id: gfx_x
        type: u2
      - id: gfx_y
        type: u2
      - id: width
        type: u2
      - id: height
        type: u2
      - id: gfx_page
        type: u1
      - id: flip_bits
        type: u1
        doc: 'Bit 0: vertical flip, bit 1: horizontal flip.'
      - id: palette_index
        type: u1
      - id: unused
        type: u1
  hitbox:
    seq:
      - id: x_pos
        type: s2
      - id: y_pos
        type: s2
      - id: width
        type: u2
      - id: height
        type: u2
  frame:
    seq:
      - id: unknown
        type: u2
      - id: num_hitboxes
        type: u1
      - id: num_parts
        type: u1
      - id: first_hitbox_offset
        type: u4
        doc: Relative to `hitbox_list_offset`.
      - id: first_part_offset
        type: u4
        doc: Relative to `part_list_offset`.
    instances:
      parts:
        pos: _root.part_list_offset + first_part_offset
        type: part
        repeat: expr
        repeat-expr: num_parts
        io: _root._io
      hitboxes:
        pos: _root.hitbox_list_offset + first_hitbox_offset
        type: hitbox
        repeat: expr
        repeat-expr: num_hitboxes
        io: _root._io
  frame_delay:
    seq:
      - id: frame_index
        type: u2
      - id: delay
        type: u2
      - id: unknown
        type: u4
  anim:
    seq:
      - id: num_frames
        type: u4
      - id: first_delay_offset
        type: u4
        doc: Relative to `frame_delay_list_offset`.
    instances:
      delays:
        pos: _root.frame_delay_list_offset + first_delay_offset
        type: frame_delay
        repeat: expr
        repeat-expr: num_frames
        io: _root._io
