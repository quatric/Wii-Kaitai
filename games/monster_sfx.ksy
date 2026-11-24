meta:
  id: monster_sfx
  title: Monster Games .sfx mono DSP (Excite Truck, ExciteBots)
  file-extension: sfx
  endian: le
doc: |
  u32 data size @0, u32 header size @4, loop byte @8, u16 codec @0xc (0 =
  DSP-ADPCM), u16 channels @0xe (must be 1), s32 sample rate @0x10, coefficients
  @0x3c, mono ADPCM at the header size. Checked against excite_360_beep.sfx.
seq:
  - id: data_size
    type: u4
  - id: header_size
    type: u4
  - id: loop_byte
    type: u4
  - id: codec
    type: u2
  - id: channels
    type: u2
  - id: sample_rate
    type: s4
  - id: unk14
    size: 0x3c - 0x14
  - id: coefs
    type: s2
    repeat: expr
    repeat-expr: 16
  - id: unk5c
    size: header_size - 0x5c
  - id: adpcm
    size: data_size
