meta:
  id: stormfront_seg
  title: Stormfront .seg sound (Wii)
  file-extension: seg
  endian: be
doc: |
  Stormfront `.seg` sound (Spiderwick Chronicles, Eragon; Wii variant). The audio
  starts at 0x4000 as 0x2000-byte blocks interleaved per channel, and the first
  block of every channel opens with its own standard 0x60-byte DSP header.
seq:
  - id: magic
    contents: ['seg', 0]
  - id: codec
    contents: ['wii', 0]
  - id: version
    type: u4
  - id: reserved0
    size: 4
  - id: len_data
    type: u4
  - id: reserved1
    size: 4
  - id: sample_rate
    type: u4
  - id: num_samples
    type: u4
  - id: loop_flag
    type: u4
  - id: num_channels
    type: u4
  - id: reserved2
    size: 0x10
  - id: name
    size: 0x48
    type: strz
    encoding: ASCII
