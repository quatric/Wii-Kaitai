meta:
  id: imaginewsn
  title: Imagine engine scene mesh (.wsn, Party Babyz)
  file-extension: wsn
  endian: be
doc: |
  After unpacking the Imagine LZ wrapper. {u32 object count, texture count, pool
  size, fill, then u32 object offsets[n], texture offsets[t], texture size
  words[t] (low 16 bits = square edge), texture format words[t] (0 RGB565,
  1 RGB5A3; 4x4 GX tiles)}. Object {u32 mesh count, ..., u32 mesh offsets[count]
  at +0x38}; mesh header 0x30 bytes {u32 vertex count, ..., u32 vertex pointer
  at +0x20}; vertex records 28 bytes {f32 x, y, z, f32 a, b, u32 ?, u8 r, g, b, a}.
seq:
  - id: object_count
    type: u4
  - id: texture_count
    type: u4
  - id: pool_size
    type: u4
  - id: fill
    type: u4
  - id: object_offsets
    type: u4
    repeat: expr
    repeat-expr: object_count
  - id: texture_offsets
    type: u4
    repeat: expr
    repeat-expr: texture_count
  - id: texture_sizes
    type: u4
    repeat: expr
    repeat-expr: texture_count
  - id: texture_formats
    type: u4
    repeat: expr
    repeat-expr: texture_count
types:
  vertex:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
      - id: a
        type: f4
      - id: b
        type: f4
      - id: unk
        type: u4
      - id: rgba
        size: 4
