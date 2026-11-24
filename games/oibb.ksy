meta:
  id: oibb
  title: OIBB object pack (Doctor Fizzwizzle's Animal Rescue)
  file-extension: pak
  endian: le
doc: |
  `OIBB` object pack (Doctor Fizzwizzle's Animal Rescue `*.pak`, SPG
  "AxEngine"): the magic, a little-endian version (4), offset tables, then a
  memory image of the game's objects. Only `TXTR` objects are decoded by
  nintoolbox (see `txtr_header`); embedded RIFF/WAVE files are carved out.
seq:
  - id: magic
    contents: OIBB
  - id: version
    type: u4
    doc: 4.
types:
  txtr_header:
    meta:
      endian: be
    doc: |
      Big-endian header following the `TXTR` tag. The object is 0x40 header +
      palette (RGB5A3, 256 / 16 entries) + GX tiles (C8 8x4, C4 8x8, RGBA8 4x4,
      width/height padded to the tile size).
    seq:
      - id: len_object
        type: u4
      - id: len_pixels
        type: u4
      - id: pointer
        type: u4
        doc: Ignored.
      - id: width
        type: u4
      - id: height
        type: u4
      - id: one0
        type: u4
      - id: gx_format
        type: u4
        enum: gx_format
      - id: one1
        type: u4
      - id: len_palette
        type: u4
enums:
  gx_format:
    6: rgba8
    8: c4
    9: c8
