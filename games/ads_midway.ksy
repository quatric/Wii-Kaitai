meta:
  id: ads_midway
  title: Midway GameCube .ads ("dhSS")
  file-extension: ads
  endian: be
doc: Gauntlet Dark Legacy. Codec 0x20 = DSP-ADPCM; a 0x60-byte DSP header per channel from 0x28.
seq:
  - id: magic
    contents: dhSS
  - id: unk4
    size: 4
  - id: codec
    type: u4
  - id: rate
    type: u4
  - id: channels
    type: u4
  - id: interleave
    type: u4
  - id: unk18
    size: 0x28 - 0x18
  - id: dsp_headers
    size: 0x60
    repeat: expr
    repeat-expr: channels
  - id: data
    size-eos: true
