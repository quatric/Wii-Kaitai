meta:
  id: imy
  title: Nippon Ichi IMY texture (.imy)
  file-extension: imy
  endian: le
doc: |
  Nippon Ichi `IMY` texture (Phantom Brave: We Meet Again, Wii). The palette
  (RGB5A3 words, RGB565 when flags bits 5-6 are 0) follows the header, then a
  pixel stream: u16 control size (0 -> u32 follows), control bytes, then the
  literal units. Control byte: `< 0x10` copies c+1 literal units, `< 0xC0`
  repeats the (c-0x10+1)-th most recently consumed literal unit, otherwise
  `(c-0xC0 & 15)+1` units are copied from the left, above, above-left or
  above-right (`c-0xC0 >> 4`). Units are 2 bytes (4 with flags bit 1). The result
  is plain GX tile order (C4 8x8, C8 8x4, RGBA8 4x4, padded to whole tiles).
seq:
  - id: magic
    contents: ['IMY', 0]
  - id: len_decoded
    type: u4
  - id: row_bytes
    type: u2
  - id: flags
    type: u1
    doc: bit 0 raw, bit 1 4-byte units.
  - id: bits_per_pixel
    type: u1
    doc: 4, 8 or 32.
  - id: height
    type: u2
  - id: num_palette_entries
    type: u2
  - id: reserved
    size: 0x10
  - id: rest
    size-eos: true
