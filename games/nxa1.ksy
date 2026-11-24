meta:
  id: nxa1
  title: Entergram NXA1 Opus (.nxa)
  file-extension: nxa
  endian: le
doc: |
  Higurashi no Naku Koro ni Hou / Gensou Rougoku no Kaleidoscope (Switch). Type
  1 is Switch Opus packets (u32 BE size + u32 final range + packet), type 2
  fixed-size packets without prefix. Data from 0x30.
seq:
  - id: magic
    size: 4
  - id: type
    type: u4
  - id: end_offset
    type: u4
  - id: rate
    type: u4
  - id: channels
    type: s2
  - id: frame_size
    type: u2
  - id: unk14
    size: 2
  - id: skip
    type: s2
  - id: unk18
    size: 0x30 - 0x18
  - id: data
    size-eos: true
