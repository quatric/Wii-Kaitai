meta:
  id: conan_str
  title: Cauldron GameCube stream (.str, Conan)
  file-extension: str
  endian: be
seq:
  - id: id
    contents: [0xfa, 0xaf, 0x00, 0x01]
  - id: rate
    type: u4
  - id: samples
    type: u4
  - id: interleave
    type: u4
  - id: dsp_info
    size: 0x20
    repeat: expr
    repeat-expr: 2
    doc: DSP coefficients, 0x20 per channel.
  - id: unk50
    size: 0x60 - 0x50
  - id: data
    size-eos: true
