meta:
  id: ea_pcm_eat
  title: Meet the Robinsons PCM stream (.eat)
  file-extension: eat
  endian: be
doc: |
  Meet the Robinsons (Wii) `data_rvl/stream/**/*.eat`. Signed 16-bit big-endian
  PCM from 0x24 to the end (interleaved when stereo).
seq:
  - id: one
    type: u2
  - id: num_channels
    type: u2
  - id: sample_rate
    type: u4
  - id: byte_rate
    type: u4
  - id: block_align
    type: u2
  - id: bits_per_sample
    type: u2
    doc: 16.
  - id: zeros
    size: 0x14
  - id: constant_0x48
    type: u4
  - id: pcm16
    size-eos: true
