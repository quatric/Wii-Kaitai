meta:
  id: dsb
  file-extension: dsb
  endian: le
  title: Nintendo DSB image (Animal Crossing: Wild World menu, DS)
doc: |
  Small palettized image format tagged `TXTR`, used for Animal Crossing:
  Wild World's DS menu graphics. Despite the shared `TXTR` tag with other
  Nintendo formats, this variant is fixed-layout and much simpler: a
  32-entry little-endian RGB555 palette at offset 0x20, followed at 0x60
  by one index/alpha byte per pixel, with the image always square (side
  length is derived from the remaining data size as `sqrt(file_size -
  0x60)`).

  Each pixel byte packs a 3-bit alpha level in bits 5..7 (scaled
  `value/7 * 255`) and a 5-bit palette index in bits 0..4. Only 128x128
  images are produced by the encoder (`EncodeDSB_RGBA` in
  `lib-dsb.c`), but the decoder accepts any square size up to 1024 that
  the file length implies.
seq:
  - id: magic
    contents: "TXTR"
  - id: header_rest
    size: 0x20 - 4
    doc: Unmodeled header bytes between the tag and the palette; not read by the decoder.
  - id: palette
    type: u2
    repeat: expr
    repeat-expr: 32
    doc: |
      32 little-endian RGB555 colors (5 bits each of red, green, blue,
      packed as `r | g<<5 | b<<10`). Only the entries actually referenced
      by `pixels` are meaningful; the encoder fills the rest with zero.
  - id: header_tail
    size: 0x60 - 0x20 - 0x40
    doc: Unmodeled bytes between the palette and the pixel plane.
instances:
  pixels:
    pos: 0x60
    size-eos: true
    doc: |
      One byte per pixel, `side * side` bytes total where `side` is the
      largest integer with `side*side <= (file size - 0x60)` (and must
      equal it exactly for the image to be valid). Bits 0..4 index
      `palette`; bits 5..7 hold a 3-bit alpha level scaled to 0..255 as
      `value/7 * 255`.
