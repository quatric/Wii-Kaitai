meta:
  id: caf
  title: tri-Crescendo CAF streamed music (Fragile Dreams)
  file-extension: caf
  endian: be
doc: |
  Chain of blocks, each with its own header: "CAF ", block size, block number,
  channel 0 offset/size at +0x10/+0x14, channel 1 at +0x18/+0x1c (offsets
  relative to the block), loop block number at +0x20, then per channel (0x2c
  bytes from +0x28) {u32 0, u32 initial ps, s16 hist1, hist2, 16 coefs}.
seq:
  - id: blocks
    type: block
    repeat: eos
types:
  block:
    seq:
      - id: magic
        contents: "CAF "
      - id: size
        type: u4
      - id: number
        type: u4
      - id: unk0c
        size: 4
      - id: ch0_offset
        type: u4
      - id: ch0_size
        type: u4
      - id: ch1_offset
        type: u4
      - id: ch1_size
        type: u4
      - id: loop_block
        type: u4
      - id: unk24
        size: 4
      - id: channel_info
        type: channel_info
        repeat: expr
        repeat-expr: 2
      - id: rest
        size: size - 0x28 - 0x2c * 2
  channel_info:
    seq:
      - id: zero
        type: u4
      - id: initial_ps
        type: u4
      - id: hist1
        type: s2
      - id: hist2
        type: s2
      - id: coefs
        type: s2
        repeat: expr
        repeat-expr: 16
