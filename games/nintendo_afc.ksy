meta:
  id: nintendo_afc
  title: Nintendo standalone AFC stream (.afc, .stx)
  file-extension: afc
  endian: be
doc: |
  Nintendo standalone AFC streams (Super Mario Sunshine, Wind Waker, Pikmin).
  Big endian on GameCube, little endian on the Switch ports (picked by where the
  4-bits-per-sample value sits at 0xA). Data from 0x20 is 2 channels interleaved
  every 9-byte AFC frame (after vgmstream `afc.c`).
seq:
  - id: len_data
    type: u4
  - id: num_samples
    type: u4
  - id: sample_rate
    type: u2
  - id: bits_per_sample
    type: u2
    doc: 4.
  - id: sixteen
    type: u2
    doc: 16.
  - id: reserved0
    size: 2
  - id: loop_flag
    type: u4
  - id: loop_start
    type: u4
  - id: reserved1
    size: 8
  - id: frames
    size-eos: true
