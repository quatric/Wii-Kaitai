meta:
  id: wii_dol
  title: Nintendo GameCube / Wii DOL executable (header)
  file-extension: dol
  endian: be
doc: |
  The 0x100-byte header of a DOL: file offsets, load addresses and sizes for up to seven
  text and eleven data sections, the BSS range and the entry point. Unused sections have
  size 0. Addresses are virtual addresses (0x80000000 based), which is what every
  address quoted in this repository refers to.

  Channels (`00000001.app` in most WADs, or the boot content named by the TMD) are plain
  DOLs, except where a title wraps its main program in LZ11: the Today & Tomorrow Channel
  stores content 1 as an LZ11 stream (`11` + 24-bit little-endian size) that its boot
  loader (content 0x0b) expands; decompress it first, then parse.
seq:
  - id: text_offsets
    type: u4
    repeat: expr
    repeat-expr: 7
  - id: data_offsets
    type: u4
    repeat: expr
    repeat-expr: 11
  - id: text_addresses
    type: u4
    repeat: expr
    repeat-expr: 7
  - id: data_addresses
    type: u4
    repeat: expr
    repeat-expr: 11
  - id: text_sizes
    type: u4
    repeat: expr
    repeat-expr: 7
  - id: data_sizes
    type: u4
    repeat: expr
    repeat-expr: 11
  - id: bss_address
    type: u4
  - id: bss_size
    type: u4
  - id: entry_point
    type: u4
  - id: padding
    size: 0x1c
