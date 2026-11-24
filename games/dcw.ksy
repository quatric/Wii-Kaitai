meta:
  id: dcw
  title: Speed 2 DC2 world file (.dcw)
  file-extension: dcw
  endian: be
doc: |
  Scene description holding per mesh set a position array {u32 0, u8 12, u32 n,
  n x f32 x3} directly followed by a UV array {u32 0, u8 8, u32 n, n x f32 x2}
  (the second copy of a pair is the z-mirrored track half), and later primitive
  records of the sets in the same order {u8 op, u16 n, n x {u16 position index,
  u16 normal index, u16 UV index}} with op 0x92 triangle list, 0x9a strip, 0x82
  quads, 0xa2 fan.
seq:
  - id: data
    size-eos: true
types:
  position_array:
    seq:
      - id: zero
        type: u4
      - id: stride
        type: u1
        doc: 12.
      - id: n
        type: u4
      - id: positions
        type: f4
        repeat: expr
        repeat-expr: n * 3
  uv_array:
    seq:
      - id: zero
        type: u4
      - id: stride
        type: u1
        doc: 8.
      - id: n
        type: u4
      - id: uvs
        type: f4
        repeat: expr
        repeat-expr: n * 2
  primitive:
    seq:
      - id: op
        type: u1
      - id: n
        type: u2
      - id: vertices
        type: vertex
        repeat: expr
        repeat-expr: n
  vertex:
    seq:
      - id: position_index
        type: u2
      - id: normal_index
        type: u2
      - id: uv_index
        type: u2
