meta:
  id: ctx_tex
  title: Bionicle Heroes texture (.CTX)
  file-extension: ctx
  endian: be
doc: |
  Bionicle Heroes (Eurocom, Wii) `*.CTX` textures; GX pixel data from 0x40. Other
  `.ctx` files (text tables) share the extension.
seq:
  - id: zero
    type: u4
  - id: width
    type: u2
  - id: height
    type: u2
  - id: gx_format
    type: u2
    enum: gx_format
  - id: num_levels
    type: u2
  - id: constant_0x34
    type: u4
  - id: reserved
    size: 0x2c
  - id: pixels
    size-eos: true
enums:
  gx_format:
    0: i4
    1: i8
    2: ia4
    3: ia8
    4: rgb565
    5: rgb5a3
    6: rgba8
    14: cmpr
