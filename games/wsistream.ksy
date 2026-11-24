meta:
  id: wsistream
  title: Aladin Magic Racer .wsi stream
  file-extension: wsi
  endian: be
doc: |
  Blocks alternate channels; the first block of each channel starts with its
  0x60-byte DSP-ADPCM header.
seq:
  - id: head_size
    type: u4
    doc: 0x20.
  - id: two
    type: u4
  - id: pad
    size: 0x18
  - id: blocks
    type: block
    repeat: eos
types:
  block:
    seq:
      - id: size
        type: u4
        doc: 0x110 including header; the last block is shorter.
      - id: one
        type: u4
      - id: channel
        type: u4
        doc: 1 or 2.
      - id: zero
        type: u4
      - id: payload
        size: size - 16
