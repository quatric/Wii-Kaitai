meta:
  id: wis
  title: Cauldron .wis block-compressed stream
  file-extension: wis
  endian: le
doc: |
  Cabela's Big Game Hunter 2010. No magic; blocks {u32 size (bit 31 = stored
  raw), payload}, each usually decoding to 0x7ffc bytes, ended by 0xffffffff
  and 0xff padding. Compressed blocks are Okumura LZSS (ring pre-filled with
  0x20, position 0xfee, LSB-first, 1 = literal, match offset = b0 | (b1&0xf0)<<4,
  length = (b1&15)+3).
seq:
  - id: blocks
    type: block
    repeat: until
    repeat-until: _.size_raw == 0xffffffff
types:
  block:
    seq:
      - id: size_raw
        type: u4
      - id: payload
        size: size_raw & 0x7fffffff
        if: size_raw != 0xffffffff
    instances:
      stored:
        value: (size_raw & 0x80000000) != 0
