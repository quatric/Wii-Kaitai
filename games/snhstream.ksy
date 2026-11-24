meta:
  id: snhstream
  title: Cosmic Family .snh voice descriptor
  file-extension: snh
  endian: be
doc: Offsets index the sibling headerless mono DSP-ADPCM pool "streams.sns".
seq:
  - id: sns_offset
    type: u4
  - id: sns_length
    type: u4
  - id: zero
    size: 8
  - id: rate
    type: u4
  - id: unk
    size: 0x28 - 0x14
  - id: coefs
    type: s2
    repeat: expr
    repeat-expr: 16
  - id: rest
    size: 86 - 0x28 - 32
