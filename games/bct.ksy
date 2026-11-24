meta:
  id: bct
  title: Nicktoons MLB environment map (.bct)
  file-extension: bct
  endian: be
doc: |
  Nicktoons MLB `*.bct` stadium environment map: a 0x30-byte header and a CMPR
  (DXT1-style) texture with its mip chain.
seq:
  - id: format
    type: u1
    doc: 6.
  - id: reserved0
    size: 3
  - id: width
    type: u2
  - id: height
    type: u2
  - id: reserved1
    size: 0x14
  - id: len_data
    type: u4
  - id: reserved2
    size: 0x10
  - id: pixels
    size-eos: true
