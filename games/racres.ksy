meta:
  id: racres
  title: Cars Race-O-Rama .gcn.res resource
  endian: le
doc: |
  Head {u32 3, u32 0x1c, u32 head size, ...}, a 0x30-byte entry block with the
  original path, zero padding to 0x800, then payload zlib streams separated by
  0xff pad bytes. A texture payload starts with a big-endian head {u32 2,
  flags, 0, 1, w, h, w, h, data size} (0x24 bytes) then GX data (CMPR).
seq:
  - id: three
    type: u4
  - id: x1c
    type: u4
  - id: head_size
    type: u4
  - id: head_rest
    size: 0x1c - 12
  - id: entry_block
    size: 0x30
  - id: pad_and_payload
    size-eos: true
