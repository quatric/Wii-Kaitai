meta:
  id: kwa
  title: Knight Wars / Aragorn's Quest audio (.kwa)
  file-extension: kwa
  endian: be
doc: |
  Knight Wars / Aragorn's Quest `.kwa` (Wii; layout after vgmstream). From 0x20
  the channels' blocks of `interleave` bytes alternate, the first block of every
  channel opening with its own standard 0x60-byte DSP header.
seq:
  - id: three
    type: u4
  - id: num_channels
    type: u4
  - id: reserved0
    size: 4
  - id: interleave
    type: u4
    doc: 0x8000.
  - id: reserved1
    size: 0x10
  - id: blocks
    size-eos: true
