meta:
  id: etx
  title: Rubik's Puzzle World texture (.etx)
  file-extension: etx
  endian: be
doc: |
  Rubik's Puzzle World (Wii) `.etx`. GX tiled pixel data (`width * height *
  bytes per pixel`) and a 24-byte zero trailer follow the header. Formats:
  `0x10` GX RGBA8, `0x12` RGB565, `0x15` I8 (other formats not handled).
seq:
  - id: width
    type: u2
  - id: height
    type: u2
  - id: format_shl_16
    type: u4
    doc: Format << 16.
  - id: pixels_and_trailer
    size-eos: true
