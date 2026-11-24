meta:
  id: ndp
  title: NDP stereo DSP music (.nds)
  file-extension: nds
  endian: le
doc: |
  `NDP\0` stereo DSP music (Pool Hall Pro `.nds`, Storm City Games). One
  standard 0x60-byte big-endian GameCube DSP header per channel follows the
  file header; the ADPCM data follows with the channels interleaved in 4-byte
  units.
seq:
  - id: magic
    contents: ['NDP', 0]
  - id: version
    type: u4
    doc: 3.
  - id: len_body
    type: u4
    doc: File size - 0x18.
  - id: sample_rate
    type: u4
  - id: num_channels
    type: u4
  - id: constant
    type: u4
    doc: 0x10.
  - id: dsp_headers
    size: 0x60
    repeat: expr
    repeat-expr: num_channels
    doc: Big-endian GameCube DSP headers, one per channel.
  - id: adpcm_data
    size-eos: true
