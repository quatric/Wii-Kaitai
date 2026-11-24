meta:
  id: gnomz_ltex
  title: Qubic Games LTEX texture (.ltex)
  file-extension: ltex
  endian: le
doc: |
  "2 Fast 4 Gnomz" and other Qubic Wii games. Pixel data starts at 0x18. When
  byte 6 is 0x10 the data is a u32 header (low 24 bits = compressed length)
  followed by an LZ11 stream. Formats 14 and 15 RGB565, 17 RGBA8888 (both
  little endian, row major).
seq:
  - id: magic
    contents: LTEX
  - id: flags
    type: u4
  - id: format
    type: u2
  - id: width
    type: u2
  - id: height
    type: u2
  - id: more_flags
    size: 8
  - id: pixels
    size-eos: true
