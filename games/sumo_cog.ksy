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
types:
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
