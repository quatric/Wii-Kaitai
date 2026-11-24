meta:
  id: nds_sadl
  title: Procyon Studio Digital Sound Elements DS audio (.sad, "sadl")
  file-extension: sad
  endian: le
doc: |
  Professor Layton, Soma Bringer, Ni no Kuni. Loop flag @0x31, channels @0x32,
  flags @0x33 (rate bit 6: 4 -> 32728 Hz else 16364 Hz; codec = flags & 0xf0:
  0x00/0x70 IMA with per-channel {s16 predictor, s16 step} at 0x80, 0xb0 Procyon
  ADPCM), data size @0x40, data start @0x48; channels interleave every 0x10 bytes.
seq:
  - id: magic
    contents: sadl
  - id: unk4
    size: 0x31 - 4
  - id: loop_flag
    type: u1
  - id: channels
    type: u1
  - id: flags
    type: u1
  - id: unk34
    size: 0x40 - 0x34
  - id: data_size
    type: u4
  - id: unk44
    size: 4
  - id: data_start
    type: u4
