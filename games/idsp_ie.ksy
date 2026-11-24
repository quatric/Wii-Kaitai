meta:
  id: idsp_ie
  title: Inevitable Entertainment GameCube IDSP (Defender)
  file-extension: idsp
  endian: be
seq:
  - id: magic
    size: 4
  - id: data_size
    type: u4
  - id: rate
    type: u4
  - id: channels
    type: u4
  - id: interleave
    type: u4
  - id: dsp_info
    size: 0x2e
    repeat: expr
    repeat-expr: channels
    doc: DSP coefficients at 0x14, 0x2e per channel.
  - id: pad
    size: 0x70 - 0x14 - 0x2e * channels
  - id: data
    size-eos: true
