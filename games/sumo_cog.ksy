meta:
  id: sumo_cog
  title: Sumo Digital COG geometry descriptors (Virtua Tennis 2009)
  file-extension: cog
  endian: be
doc: |
  The .cog is an object graph (not modelled); per mesh a block of 16-byte
  attribute descriptors ends with a 0x0F descriptor and is followed, aligned to
  0x20, by a GX display list. The matching .gog holds vertex pools: positions
  3 x f32, normals s8 x 3 (/64), texcoords u16 x 2 (/512).
seq:
  - id: descriptors
    type: descriptor
    repeat: until
    repeat-until: _.attribute == 0x0f
  - id: align_pad
    size: (0x20 - (_io.pos % 0x20)) % 0x20
    doc: Alignment to 0x20 (relative to the start of this stream; slice the .cog at a 0x20-aligned mesh start).
  - id: draw_commands
    type: draw_command
    repeat: until
    repeat-until: _.is_end or _io.eof
types:
  draw_command:
    seq:
      - id: opcode
        type: u1
        doc: 0x80 quads, 0x90 triangles, 0x98 strip, 0xA0 fan; anything else ends the list.
      - id: vertex_count
        type: u2
        if: not is_end
      - id: vertices
        type: vertex
        repeat: expr
        repeat-expr: vertex_count
        if: not is_end
    instances:
      is_end:
        value: opcode != 0x80 and opcode != 0x90 and opcode != 0x98 and opcode != 0xa0
  vertex:
    seq:
      - id: indices
        type: index(_index)
        repeat: expr
        repeat-expr: _root.descriptors.size - 1
        doc: One index per descriptor, in order (the 0x0F terminator excluded).
  index:
    params:
      - id: i
        type: s4
    seq:
      - id: narrow
        type: u1
        if: _root.descriptors[i].index_width == 1
      - id: wide
        type: u2
        if: _root.descriptors[i].index_width != 1

  descriptor:
    seq:
      - id: attribute
        type: u1
        doc: 3 position, 6 normal, 8/10 colour, 11 texcoord, 0x0f end.
      - id: index_width
        type: u1
        doc: 1 or 2.
      - id: flags
        size: 2
      - id: component_type
        type: u1
        doc: 0 u8, 1 s8, 2 u16, 3 s16, 4 f32.
      - id: count_code
        type: u1
      - id: frac
        type: u1
      - id: unk
        type: u1
      - id: stride
        type: u1
      - id: pad
        size: 3
      - id: gog_offset
        type: u4
