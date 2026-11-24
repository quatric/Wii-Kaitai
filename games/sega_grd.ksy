meta:
  id: sega_grd
  title: SEGA GRD atlas (Sakura Wars)
  endian: le
doc: |
  Atlas textures ("PVRT" kind 0x64, pixel format 9, 256 x 256) use the 256-entry
  RGBA palette of the MPLN chunk and a swizzled index order: with i the byte
  index, target bit k of the position (k = 0..7 x, 8..15 y) is the parity of
  (i & mask[k]) for mask = 512 1024 2048 4096 8192 128 256 32768 | 4 8 9233 2 32 64
  16400 16, then the picture is rotated a quarter turn: pixel (255 - y, x).
seq:
  - id: data
    size-eos: true
