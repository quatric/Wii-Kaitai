meta:
  id: imagine_msk
  title: Imagine engine 8-bit mask (.msk)
  file-extension: msk
  endian: le
doc: |
  Ubisoft Imagine engine `.msk` 8-bit mask (Babysitting Party, Babyz, Beastly;
  inside the LZSS wrapper, see `imagine_lz`). Row-major 8-bit values.
seq:
  - id: width
    type: u4
  - id: height
    type: u4
  - id: padding
    size: 16
    doc: 0xCC.
  - id: values
    size: width * height
