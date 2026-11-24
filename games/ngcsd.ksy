meta:
  id: ngcsd
  title: _NGCSD02 sound stream (Totally Spies! Totally Party)
  endian: be
doc: |
  After the header, one 0x60-byte DSP header per channel from +0x18, then the
  ADPCM frames interleaved one 8-byte frame per channel. Trailing data is a
  lower-rate copy / cue data. Flag 0 mono, 1 mono + trailing data, 2 stereo +
  trailing data.
seq:
  - id: magic
    contents: _NGCSD02
  - id: duration
    type: f4
  - id: samples
    type: u4
  - id: unk10
    size: 2
  - id: flag
    type: u1
  - id: unk13
    size: 5
  - id: dsp_headers
    size: 0x60
    repeat: expr
    repeat-expr: '(flag == 2 ? 2 : 1)'
  - id: data
    size-eos: true
