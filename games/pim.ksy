meta:
  id: pim
  title: Dokapon Kingdom texture (.PIM)
  file-extension: pim
  endian: le
doc: |
  Dokapon Kingdom `.PIM` texture (Sting, Wii; PS2-derived). Indexed images carry
  an RGBA palette of 4-byte entries whose alpha is the PS2 range 0..0x80,
  followed by linear indices (4-bit ones low nibble first). 32-bit images are
  plain RGBA with the same alpha range.
seq:
  - id: width
    type: u2
  - id: height
    type: u2
  - id: bits_per_pixel
    type: u2
    doc: 4, 8 or 32.
  - id: num_palette_entries
    type: u2
  - id: palette_offset
    type: u2
    doc: 16.
  - id: zero0
    type: u2
  - id: pixel_data_offset
    type: u2
  - id: zero1
    type: u2
