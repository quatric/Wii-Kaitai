meta:
  id: htex
  title: Sega / Red Entertainment HTEX texture (.htx, Sakura Wars)
  file-extension: htx
  endian: le
doc: |
  PS2-lineage 8-bit texture: "HTEX" header (0x10), "HTSF" (0x10), then a "PVRT"
  block {"PVRT", u32 size, u8 pixel format 9, u8 data format 0x6c, u16 0, u16
  width, u16 height} followed by a 256-entry RGBA palette (alpha 0x80 = opaque,
  PS2 CLUT order: entries 8..15 and 16..23 of every 32 swapped) and width *
  height 8-bit indices in PS2 GS PSMT8 block-swizzled order. The "GBIX" flavour
  (unpalettised wipe masks) is different.
seq:
  - id: htex
    contents: HTEX
  - id: htex_rest
    size: 12
  - id: htsf
    contents: HTSF
  - id: htsf_rest
    size: 12
  - id: pvrt
    contents: PVRT
  - id: size
    type: u4
  - id: pixel_format
    type: u1
  - id: data_format
    type: u1
  - id: zero
    type: u2
  - id: width
    type: u2
  - id: height
    type: u2
  - id: palette
    size: 256 * 4
  - id: indices
    size: width * height
