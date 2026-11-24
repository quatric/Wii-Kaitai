meta:
  id: acbivt
  title: ACB Total / Planet Basket .ivt texture
  file-extension: ivt
doc: |
  8-byte header then XOR-scrambled pixels. Byte 0 = base + log2(width) + 8 *
  log2(height) with base 165 (32-bit) / 101 (24-bit) / 37 (2 byte) / 229
  (1 byte); byte 1 = key variant (0: 99 44 87, 1: ba 8c ab 9e 99, 2: b0 8f be
  93 9a 8d b2); bytes 2..7 constant per variant. After XOR: BGRA8 / BGR8 /
  luminance+alpha / luminance.
seq:
  - id: size_byte
    type: u1
  - id: key_variant
    type: u1
  - id: constant
    size: 6
  - id: pixels
    size-eos: true
