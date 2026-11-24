meta:
  id: wittex
  title: Fun Labs .wit texture (Jurassic The Hunted, Cabela's)
  file-extension: wit
  endian: le
doc: Cabela's files have a u32 name hash first and data at 0x18.
seq:
  - id: width
    type: u4
  - id: height
    type: u4
  - id: format
    type: u4
    doc: 0 I4, 1 I8, 2 IA4, 3 IA8, 4 RGB565, 5 RGB5A3, 6 RGBA8, 14 CMPR.
  - id: levels
    type: u4
  - id: pixels
    size-eos: true
    doc: GX pixel data.
