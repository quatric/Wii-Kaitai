meta:
  id: dspstr
  title: Despicable Me stereo DSP stream (.str)
  file-extension: str
  endian: be
doc: Frames interleave 8 bytes left / 8 bytes right. No sample rate stored (32 kHz assumed).
seq:
  - id: data_bytes
    type: u4
    doc: File size - 0x54.
  - id: channels
    type: channel
    repeat: expr
    repeat-expr: 2
  - id: data
    size-eos: true
types:
  channel:
    seq:
      - id: coefs
        type: s2
        repeat: expr
        repeat-expr: 16
      - id: gain
        type: u2
      - id: initial_ps
        type: u2
      - id: hist1
        type: s2
      - id: hist2
        type: s2
