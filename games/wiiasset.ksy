meta:
  id: wiiasset
  title: We Wish You a Merry Christmas compiled asset
  endian: be
doc: |
  ASSETS/<id>. Type specific headers follow. "SND\0": u32 0x28, u32 size,
  f32 volume, u32 rate, u32 channels, 0x60-byte DSP header at 0x38, ADPCM at
  0x98. "BMP\0": u32 0xc, u32 data bytes, u16 format (3 CMPR, 6 RGB565,
  7 RGB5A3), u16 width, u16 height, u16 mips, u32 flags, data at 0x1c.
seq:
  - id: container_version
    type: u2
  - id: asset_version
    type: u2
  - id: type
    size: 4
  - id: body
    size-eos: true
