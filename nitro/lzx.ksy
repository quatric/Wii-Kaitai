meta:
  id: lzx
  endian: le
  title: Extended LZ11 (0x19) compression wrapper
doc: |
  "LZX"/Extended-LZ11 compression, ported from lib-lzx.c (split out of
  Wiimms SZS Tools' lib-nintendo.c, documented there as "0x19 Extended
  LZ11"). Same 4-byte header shape as LZ10/LZ11 (magic byte + 24-bit
  little-endian decompressed size) but with its own flag-group encoding
  for the token stream that follows.
seq:
  - id: magic
    contents: [0x19]
  - id: size_lo24
    type: u1
    repeat: expr
    repeat-expr: 3
    doc: The 3 low-to-high bytes of the 24-bit decompressed size.
  - id: token_stream
    size-eos: true
instances:
  decoded_size:
    value: 'size_lo24[0].as<u4> | (size_lo24[1].as<u4> << 8) | (size_lo24[2].as<u4> << 16)'
