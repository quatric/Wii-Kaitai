meta:
  id: k11_a2
  title: K11 - Kommissare im Einsatz texture (.a2)
  file-extension: a2
  endian: be
doc: |
  K11 - Kommissare im Einsatz (Germany, Wii) `.a2` texture
  (`wii/Characters/Textures/*`). The first level is in GX tile layout from
  0x1C; further mip levels follow it.
seq:
  - id: format
    type: u4
    enum: gx_format
  - id: width
    type: u4
  - id: height
    type: u4
  - id: num_mips
    type: u4
  - id: zero0
    type: u4
  - id: zero1
    type: u4
  - id: len_first_level
    type: u4
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
