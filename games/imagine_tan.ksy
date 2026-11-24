meta:
  id: imagine_tan
  title: Imagine engine animated 2D texture (.tan)
  file-extension: tan
  endian: be
doc: |
  Ubisoft Imagine engine `.tan` animated 2D texture (Babysitting Party, Babyz,
  Beastly face/mouth animations; inside the LZSS wrapper). A 0x210-byte RGB565
  palette (256 used entries), then `frames` GX C8 images (8x4 tiles).
seq:
  - id: num_frames
    type: u4
  - id: width
    type: u4
  - id: height
    type: u4
  - id: zero
    type: u4
  - id: palette
    size: 0x210
  - id: frames_data
    size-eos: true
