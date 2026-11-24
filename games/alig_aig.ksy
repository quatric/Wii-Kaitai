meta:
  id: alig_aig
  title: ALIG GX texture (.aig)
  file-extension: aig
  endian: le
doc: |
  `ALIG` GX texture (Shonen Jump's One Piece: Unlimited Adventure, Wii
  `material/*.aig`). A 0x40-byte header (mostly little endian, the level-0 size
  is big endian) followed by GX tiled pixel data; mip levels follow level 0.
  Formats: `GIA4` IA4, `G5A3` RGB5A3, `G565` RGB565, `GC32` RGBA8, `GCCP` /
  `GACC` CMPR.
seq:
  - id: magic
    contents: ALIG
  - id: version
    type: u2
    doc: 0x0102.
  - id: pad
    size: 2
  - id: format
    type: str
    size: 4
    encoding: ASCII
  - id: zero
    type: u4
  - id: width
    type: u2
  - id: height
    type: u2
  - id: one
    type: u4
  - id: constant_0x10
    type: u4
  - id: constant_0x40
    type: u4
  - id: len_level0
    type: u4be
  - id: reserved
    size: 0x1c
  - id: pixels
    size-eos: true
