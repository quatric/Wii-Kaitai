meta:
  id: asobo_vai
  title: Asobo Studio GameCube stereo DSP (.vai, Ratatouille)
  file-extension: vai
  endian: be
doc: File = data size + 0x4060; ADPCM from 0x4060 interleaved every 0x4000 bytes.
seq:
  - id: rate
    type: u4
  - id: data_size
    type: u4
  - id: unk8
    size: 4
  - id: dsp_info
    size: 0x20
    repeat: expr
    repeat-expr: 2
    doc: DSP coefficients @0xc, 0x20 per channel.
  - id: pad
    size: 0x4060 - 0x4c
  - id: data
    size-eos: true
