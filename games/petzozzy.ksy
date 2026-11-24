meta:
  id: petzozzy
  title: Petz / Magma engine level container (.ozzy)
  file-extension: ozzy
  endian: be
doc: |
  u32 0, then chunks {u32 raw size (<= 0x4000), u32 zlib size, zlib data} and a
  4-byte trailer. The inflated stream is an "LV3D" scene of big-endian packed
  records: "MESH" nodes name a "GEOM" (u32 version 3/4, u32 vertex count, u32 0,
  u32 flags, then attribute blocks {u32 count, u32 0, u8 stride, u8 0, u8
  semantic, u8 type, u8 components, u8 0, u8 fraction bits, u32 byte size, data};
  semantic 1 position, 2 normal, 3 colour, 5 texcoord), a GX display list, and
  the diffuse texture path; "TEXT" records followed by "TTPL" (u32 size + Wii
  TPL) carry textures.
seq:
  - id: zero
    type: u4
  - id: chunks
    type: chunk
    repeat: until
    repeat-until: _.raw_size == 0
types:
  chunk:
    seq:
      - id: raw_size
        type: u4
      - id: zlib_size
        type: u4
        if: raw_size != 0
      - id: zlib_data
        size: zlib_size
        if: raw_size != 0
  attribute_block:
    seq:
      - id: count
        type: u4
      - id: zero0
        type: u4
      - id: stride
        type: u1
      - id: zero1
        type: u1
      - id: semantic
        type: u1
      - id: type
        type: u1
      - id: components
        type: u1
      - id: zero2
        type: u1
      - id: fraction_bits
        type: u1
      - id: byte_size
        type: u4
      - id: data
        size: byte_size
