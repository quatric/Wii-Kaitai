meta:
  id: mh2_wrld
  title: Manhunt 2 world vertex buffer record (.bsp WRLD)
  file-extension: bsp
  endian: be
doc: |
  World geometry references vertex buffers through 24-byte records {u16 id,
  u16 users, u32 size, u32 data offset, 2 x u32 0}; a buffer is an array of
  16-byte entries {f32 x, y, z, 0}. Polygon and index tables are not decoded.
seq:
  - id: body
    size-eos: true
types:
  buffer_record:
    seq:
      - id: id
        type: u2
      - id: users
        type: u2
      - id: size
        type: u4
      - id: data_offset
        type: u4
      - id: zero
        size: 8
  vertex:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
      - id: zero
        type: f4
