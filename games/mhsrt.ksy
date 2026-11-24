meta:
  id: mhsrt
  title: Capcom MT Framework sound resource table (.srt, Monster Hunter Tri)
  file-extension: srt
  endian: be
doc: |
  {u32 chunk offsets..., 0} then 16-byte-headed chunks tagged "RND", "SSD",
  "SRT", "DSP". The "DSP" chunk: {tag, u32 count, u32 0x10, 0}, a u32 offset
  table padded to 16, count 0x90-byte entries: +8 rate, +0xc first byte =
  channels - 1, per channel {u32 end, u32 current (2), 16 x s16 coefficients,
  u16 gain, u16 initial ps ...} at +0x18 and +0x58. The .ssd is headerless
  8-byte DSP frames block-interleaved by 0x10000 bytes.
seq:
  - id: chunk_offsets
    type: u4
    repeat: until
    repeat-until: _ == 0
  - id: rest
    size-eos: true
types:
  dsp_entry:
    seq:
      - id: unk0
        size: 8
      - id: rate
        type: u4
      - id: channels_minus_one
        type: u1
      - id: unk0d
        size: 0x18 - 0x0d
      - id: ch0
        type: channel
      - id: unk_mid
        size: 0x58 - 0x18 - 0x24
      - id: ch1
        type: channel
  channel:
    seq:
      - id: end
        type: u4
      - id: current
        type: u4
      - id: coefs
        type: s2
        repeat: expr
        repeat-expr: 16
      - id: gain
        type: u2
      - id: initial_ps
        type: u2
