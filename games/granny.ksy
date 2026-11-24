meta:
  id: granny
  title: Granny 2 .gr2 (big-endian 32-bit Wii variant)
  file-extension: gr2
  endian: be
doc: |
  Magic B5 95 11 0E 4B B5 A5 6A 50 28 28 EB 04 B3 78 25. Sections stored
  uncompressed; pointers come from per-section relocation tables and the object
  layout from the embedded type definitions.
seq:
  - id: magic
    contents: [0xb5, 0x95, 0x11, 0x0e, 0x4b, 0xb5, 0xa5, 0x6a, 0x50, 0x28, 0x28, 0xeb, 0x04, 0xb3, 0x78, 0x25]
  - id: header_size
    type: u4
  - id: header_format
    type: u4
  - id: reserved
    size: 8
  - id: rest
    size-eos: true
