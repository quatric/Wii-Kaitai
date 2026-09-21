meta:
  id: huff
  file-extension: huff
  endian: le
  title: Nintendo Huffman-compressed stream
doc: |
  Nintendo's general-purpose Huffman compression, as used across GBA/DS/Wii
  titles (the same on-disk shape as the public "CompressHuff" tooling).
  A one-byte tag selects 4-bit or 8-bit symbols, followed by a 24-bit
  little-endian uncompressed size (falling back to an extra 32-bit size
  word when that field is 0), a Huffman tree stored as paired child
  bytes, and the bitstream itself, read 32 bits at a time. Ported from
  lib-huff.c's `DecodeNintendoHuff`/`EncodeNintendoHuff`.
seq:
  - id: tag
    type: u1
    enum: symbol_width
  - id: size24_raw
    size: 3
    doc: |
      24-bit little-endian uncompressed size; all-zero means the real size
      follows as `size32`. See `uncompressed_size` for the resolved value.
  - id: size32
    type: u4
    if: size24_raw[0] == 0 and size24_raw[1] == 0 and size24_raw[2] == 0
    doc: Present only when `size24_raw` is all zero.
  - id: tree_size_byte
    type: u1
    doc: Tree byte-size is `2 * (tree_size_byte + 1)`.
  - id: tree
    size: 2 * (tree_size_byte + 1)
    doc: |
      Paired child-node bytes, root at index 0/1. Each byte's low 6 bits
      encode the child-pair offset (from this node's own aligned pair);
      bit 0x80 (for the "0" child) / 0x40 (for the "1" child) marks that
      child as a leaf symbol byte rather than another internal node.
  - id: bitstream
    size-eos: true
    doc: |
      Huffman-coded bits, packed 32 per little-endian u32 word, MSB first
      within each word. 4-bit mode packs two decoded nibbles per output byte.
instances:
  is_size32:
    value: size24_raw[0] == 0 and size24_raw[1] == 0 and size24_raw[2] == 0
  uncompressed_size:
    value: 'is_size32 ? size32 : size24_raw[0] + (size24_raw[1] << 8) + (size24_raw[2] << 16)'
enums:
  symbol_width:
    0x24: bits_4
    0x28: bits_8
