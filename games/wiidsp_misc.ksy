meta:
  id: wiidsp_misc
  title: Single-stream DSP-ADPCM wrappers (GCA1 / Monster Games .sfx)
  endian: be
doc: |
  Terminal Reality "GCA1" (.gca, Metal Slug Anthology): coefficients @4 (16 x s16
  BE), u32 BE nibble count @0x26, u32 BE sample rate @0x2a, mono ADPCM from 0x40.
  Monster Games ".sfx" (Excite Truck, ExciteBots; little endian): u32 data size
  @0, u32 header size @4, loop byte @8, u16 codec @0xc (0 = DSP-ADPCM), u16
  channels @0xe (must be 1), s32 sample rate @0x10, coefficients @0x3c, mono ADPCM
  at the header size.
seq:
  - id: magic
    contents: GCA1
  - id: coefs
    type: s2
    repeat: expr
    repeat-expr: 16
  - id: unk24
    size: 2
  - id: nibble_count
    type: u4
  - id: sample_rate
    type: u4
  - id: pad
    size: 0x40 - 0x2e
  - id: adpcm
    size-eos: true
