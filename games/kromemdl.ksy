meta:
  id: kromemdl
  title: Krome Studios .mdl / .mdg static models (Star Wars TFU, Wii)
  endian: be
doc: |
  "MDL3" holds names and bounds, the "MDG3" companion the geometry as chunks:
  0x20-byte field block at f {u16 x4 (4th = strip count), u16 0xffff, u16 flags,
  .., u32 colour table offset (from f + 0x20), u32 colour table size, u32
  position array size, u32 UV array size}; strips at f + 0x20 {u8 op (0x98 strip,
  0x90 list, 0xa0 fan), u16 n, n x 9-byte records {u16 position index, s8 x3
  normal (/64), [6 tangent bytes in the 15-byte records of op 0x9a / 0x92 / 0xa2
  (skinned)], u16 colour index, u16 UV index}}; colour table (rgba8), f32 x3
  positions and s16 x2 UVs (/4096) follow; the next chunk starts right behind
  the UV array.
seq:
  - id: magic
    size: 4
    doc: '"MDL3" or "MDG3".'
  - id: rest
    size-eos: true
types:
  field_block:
    seq:
      - id: counts
        type: u2
        repeat: expr
        repeat-expr: 4
      - id: ffff
        type: u2
      - id: flags
        type: u2
      - id: unk
        size: 4
      - id: colour_table_offset
        type: u4
      - id: colour_table_size
        type: u4
      - id: position_array_size
        type: u4
      - id: uv_array_size
        type: u4
  strip_vertex:
    seq:
      - id: position_index
        type: u2
      - id: normal
        type: s1
        repeat: expr
        repeat-expr: 3
      - id: colour_index
        type: u2
      - id: uv_index
        type: u2
