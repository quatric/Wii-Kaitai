meta:
  id: asurasfx
  title: Rebellion Asura .sfx stereo DSP stream
  file-extension: sfx
  endian: be
doc: Each channel block is {16 x s16 coefs, ..., u16 gain @+0x20, u16 initial ps @+0x22, ADPCM @+0x30}.
seq:
  - id: zero
    type: u4
  - id: two_a
    type: u4
  - id: two_b
    type: u4
  - id: nibbles
    type: u4
  - id: rate
    type: u4
  - id: ch0_offset
    type: u4
  - id: ch1_offset
    type: u4
