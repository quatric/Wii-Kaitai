meta:
  id: txw
  title: Tony Hawk Ride .txw frontend image
  file-extension: txw
  endian: be
doc: |
  0x40-byte header {"\xaf\xaf\x00\x02", ..., 0xbeefface at +0x0c, u16 1, u16
  type at +0x10 (2 CMPR, 4 8-bit intensity), u16 width, u16 height at +0x14,
  ...} then the GX-tiled image.
seq:
  - id: magic
    contents: [0xaf, 0xaf, 0x00, 0x02]
  - id: unk4
    size: 8
  - id: beefface
    type: u4
  - id: one
    type: u2
  - id: type
    type: u2
  - id: width
    type: u2
  - id: height
    type: u2
  - id: unk18
    size: 0x40 - 0x18
  - id: pixels
    size-eos: true
