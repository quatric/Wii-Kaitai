meta:
  id: ktss
  title: Koei Tecmo Switch KTSS audio (.kns / .kno / .ktss)
  file-extension: ktss
  endian: le
doc: |
  Hyrule Warriors, Fire Emblem Warriors, Atelier Lydie & Suelle. Codec 2 =
  DSP-ADPCM, 9 = Opus. DSP coefficients are LE s16 x 16 per channel at 0x40
  (version 1, spacing 0x2e) or 0x5c (version 3, spacing 0x60); channels
  interleave every 8 bytes. Data start = u32 @0x24 + 0x20.
seq:
  - id: magic
    size: 4
  - id: data_size
    type: u4
  - id: unk8
    size: 0x20 - 8
  - id: codec
    type: u2
  - id: version
    type: u2
  - id: data_start_minus_0x20
    type: u4
  - id: tracks
    type: u1
  - id: channels_per_track
    type: u1
  - id: unk2a
    size: 2
  - id: rate
    type: u4
  - id: samples
    type: u4
  - id: rest
    size-eos: true
