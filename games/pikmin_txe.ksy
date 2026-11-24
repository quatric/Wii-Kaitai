meta:
  id: pikmin_txe
  title: Pikmin 1 texture (.txe)
  file-extension: txe
  endian: be
doc: |
  Pikmin 1 `.txe` texture. Pixel data is GX tiled from 0x20. Format (low byte of
  the u16; Pikmin's own enum): 0 RGB565, 1 CMPR, 2 RGB5A3, 3 I4, 4 I8, 5 IA4,
  6 IA8, 7 RGBA8.
seq:
  - id: width
    type: u2
  - id: height
    type: u2
  - id: format
    type: u2
    doc: Low byte only.
  - id: unknown
    type: u2
  - id: padding
    size: 28
  - id: pixels
    size-eos: true
