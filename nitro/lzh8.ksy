meta:
  id: lzh8
  endian: le
  title: Nintendo LZH8 (0x40) compression wrapper
doc: |
  Nintendo's Huffman+LZ "LZH8" compression, ported from lib-lzh8.c (a
  buffer-based port of hcs's public-domain reference). The core header
  is a single little-endian u32 whose low byte is the 0x40 magic and
  whose upper 24 bits hold the decompressed size. Some titles (e.g.
  WarioWare: Snapped!) prefix that with one extra little-endian u32
  giving an outer size before the real 0x40 header; this definition
  models the common case with no such prefix.
seq:
  - id: header
    type: u4
    doc: 'Low byte: magic 0x40. Upper 24 bits: decompressed size.'
    valid:
      expr: header & 0xff == 0x40
  - id: compressed_stream
    size-eos: true
instances:
  decompressed_size:
    value: header >> 8
