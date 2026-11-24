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
  - id: gbix_tag
    contents: GBIX
    if: has_gbix
  - id: gbix_size
    type: u4
    if: has_gbix
  - id: gbix_body
    size: gbix_size
    if: has_gbix
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
    if: data_format == 0x6c
    doc: Only the palettised flavour (data format 0x6c) carries a palette.
  - id: indices
    size: width * height
instances:
  has_gbix_tag:
    pos: 0x20
    size: 4
  has_gbix:
    value: has_gbix_tag == [0x47, 0x42, 0x49, 0x58]
    doc: The unpalettised "wipe mask" flavour has a GBIX chunk before PVRT.
