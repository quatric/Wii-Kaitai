meta:
  id: ish_isd
  title: GameCube ISH header (Pokemon XD, Chaos Field)
  file-extension: ish
  endian: be
doc: The companion .isd holds raw interleaved DSP-ADPCM. DSP coefficients @0x40 with 0x40 per channel.
seq:
  - id: magic
    contents: I_SF
  - id: unk4
    size: 4
  - id: rate
    type: u4
  - id: samples
    type: u4
  - id: unk10
    size: 4
  - id: channels
    type: u4
  - id: interleave
    type: u4
  - id: unk1c
    size: 0x40 - 0x1c
  - id: dsp_info
    size: 0x40
    repeat: expr
    repeat-expr: channels
