meta:
  id: waud
  title: waud raw PCM sound
  endian: be
doc: Cook Wars / Cooking Party / Imagine Fashion Idol .wtxs effects and .wtss music.
seq:
  - id: magic
    contents: waud
  - id: bytes_per_sample
    type: u1
    doc: 1 = unsigned 8 bit, 2 = big-endian s16.
  - id: channels
    type: u1
  - id: streamed
    type: u1
    doc: 1 on the streamed .wtss.
  - id: zero0
    type: u1
  - id: sample_rate
    type: b24
  - id: zero1
    type: u1
  - id: data_pages
    type: u2
    doc: Data size in 256-byte pages.
  - id: flags
    type: u2
  - id: pad
    size: 0x12
  - id: samples
    size-eos: true
    doc: Interleaved when stereo.
