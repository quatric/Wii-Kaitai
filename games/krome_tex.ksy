meta:
  id: krome_tex
  title: Krome Studios texture (.tex)
  file-extension: tex
  endian: be
doc: |
  Krome Studios `.tex` (Star Wars: The Force Unleashed, Wii). GX pixel data with
  the whole mip chain from 0x20; file size is `0x20 + data size`.
seq:
  - id: format
    type: u4
    enum: gx_format
  - id: width
    type: u4
  - id: height
    type: u4
  - id: len_data
    type: u4
  - id: zero
    type: u4
  - id: mip_levels_minus_1_shl_16
    type: u4
  - id: unknown0
    type: u4
  - id: unknown1
    type: u4
  - id: pixels
    size: len_data
enums:
  gx_format:
    0: rgba8
    0x4b: ia8
    0x4c: cmpr
