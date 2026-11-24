meta:
  id: midway_tim
  title: Midway TIM texture (.tim)
  file-extension: tim
  endian: be
doc: |
  Midway `TIM` texture (members of TNA Impact! `.WAD` packs). 8 bpp is GX-tiled
  C8 (8x4 tiles) with a 256-entry palette stored as two 512-byte planes
  (`{G,R}` pairs then `{A,B}` pairs); 32 bpp is GX RGBA32.
seq:
  - id: reserved
    size: 0x20
  - id: width
    type: u4
  - id: height
    type: u4
  - id: bits_per_pixel
    type: u4
    doc: 8 or 32.
  - id: len_pixels
    type: u4
  - id: pixel_data_offset
    type: u4
    doc: 0xc0.
  - id: num_colors
    type: u4
    doc: 256 for 8 bpp.
  - id: palette_offset
    type: u4
