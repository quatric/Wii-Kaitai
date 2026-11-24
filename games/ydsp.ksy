meta:
  id: ydsp
  title: Yuke's YDSP stream
  file-extension: ydsp
  endian: be
doc: |
  WWE Day of Reckoning / WrestleMania XIX. Coefficients at 0x20 (0x24 per
  channel); DSP-ADPCM from 0x120, interleaved in blocks of `interleave` bytes.
seq:
  - id: magic
    contents: YDSP
  - id: unk4
    size: 4
  - id: data_bytes
    type: u4
    doc: All channels.
  - id: rate
    type: u4
  - id: channels
    type: u2
  - id: unk12
    size: 2
  - id: interleave
    type: u4
  - id: unk18
    size: 8
  - id: coef_blocks
    size: 0x24
    repeat: expr
    repeat-expr: channels
  - id: gap
    size: 0x120 - 0x20 - 0x24 * channels
  - id: data
    size-eos: true
