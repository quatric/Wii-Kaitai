meta:
  id: timg
  title: Cursed Mountain .timg texture
  file-extension: timg
  endian: be
seq:
  - id: magic
    contents: [0xae, 0xfe, 0x00, 0x03]
  - id: one
    type: u1
  - id: mip_levels
    type: u1
  - id: zero0
    type: u2
  - id: width
    type: u2
  - id: zero1
    type: u2
  - id: height
    type: u2
  - id: zero2
    type: u2
  - id: base_size_div_32
    type: u2
  - id: format
    type: u1
    doc: 6 RGB5A3, 7 RGBA8, 8 CMPR, 0xb I8, 0xc IA8.
  - id: unk13
    size: 0x0d
  - id: level_descriptors
    size: 0x20
    repeat: expr
    repeat-expr: mip_levels
    doc: Descriptors are not parsed; pixel data follows (0x20 * levels).
  - id: data
    size-eos: true
