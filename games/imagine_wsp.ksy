meta:
  id: imagine_wsp
  title: Imagine engine sprite (.wsp)
  file-extension: wsp
  endian: le
doc: |
  Ubisoft Imagine engine `.wsp` sprite (Babysitting Party, Babyz, Beastly;
  inside the LZSS wrapper). The GX tiles cover the width rounded up to 4 and the
  height rounded up likewise.
seq:
  - id: gx_format
    type: u4
    enum: gx_format
  - id: width
    type: u4
  - id: height
    type: u4
  - id: padding
    size: 0x14
    doc: 0xCC.
  - id: tiles
    size-eos: true
enums:
  gx_format:
    4: rgb565
    5: rgb5a3
    6: rgba8
