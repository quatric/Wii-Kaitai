meta:
  id: eabank
  title: EA Grand Slam Tennis sound bank (.sbr)
  file-extension: sbr
  endian: be
doc: |
  "SBKR" bank index; the sibling .sbs holds the streams ("SBKS"). Tag list at
  0xb0, from 0xbc count * 10-byte entries {u32 sound id, u16 2, u32 record ptr};
  a record is {u32 0, u16 ptr to stream header, u16 1, u32 ptr to stream offset,
  u32 0}. EAAC stream header: {u32 version:4, codec:4 (4 = XAS v1), channel
  config:6, rate:18; u32 type:2, loop:1, samples:29}.
seq:
  - id: magic
    contents: SBKR
  - id: unk
    size: 0x1c - 4
  - id: count
    type: u4
  - id: pad
    size: 0xbc - 0x20
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: sound_id
        type: u4
      - id: two
        type: u2
      - id: record_ptr
        type: u4
