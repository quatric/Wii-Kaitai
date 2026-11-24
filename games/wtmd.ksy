meta:
  id: wtmd
  title: CRI-style WTMD texture (Arc Rise Fantasia)
  file-extension: wtm
  endian: be
seq:
  - id: magic
    contents: WTMD
  - id: header_size
    type: u4
    doc: 0x20.
  - id: width
    type: u2
  - id: height
    type: u2
  - id: gx_format
    type: u1
    doc: 4 RGB565, 6 RGBA8, 8 CI4, 9 CI8, 14 CMPR.
  - id: palette_format
    type: u1
    doc: 1 RGB565, 2 RGB5A3, 3 IA8, 0 none.
  - id: flags
    size: 2
  - id: pixel_offset
    type: u4
  - id: unk
    type: u4
    doc: 0x20000 / 0x10000.
  - id: pad
    size: 8
  - id: palette
    size: pixel_offset - 0x20
    doc: 16 or 256 entries.
  - id: pixels
    size-eos: true
