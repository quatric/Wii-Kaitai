meta:
  id: dspbnk
  title: Blazing Angels weapon sound bank (_*.bnk)
  file-extension: bnk
  endian: be
doc: |
  A single DSP header then two equal ADPCM halves (left, right) of
  ceil(samples / 14) * 8 bytes each rounded up to 0x20; file size = 0x60 + 2 *
  half. Only one coefficient set is stored.
seq:
  - id: samples
    type: u4
  - id: nibbles
    type: u4
  - id: rate
    type: u4
  - id: loop_format_coefs
    size: 0x60 - 12
  - id: data
    size-eos: true
