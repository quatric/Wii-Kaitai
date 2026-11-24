meta:
  id: eatpcm
  title: Meet the Robinsons .eat PCM stream
  file-extension: eat
  endian: be
seq:
  - id: one
    type: u2
  - id: channels
    type: u2
  - id: sample_rate
    type: u4
  - id: byte_rate
    type: u4
  - id: block_align
    type: u2
  - id: bits
    type: u2
    doc: 16.
  - id: zero
    size: 0x14
  - id: x48
    type: u4
  - id: pcm
    size-eos: true
    doc: Signed 16-bit big-endian, interleaved when stereo.
