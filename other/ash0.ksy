meta:
  id: ash0
  file-extension: ash0
  endian: be
  title: Nintendo ASH0 compression wrapper
doc: |
  A Huffman+LZ compression format used across several Nintendo
  DS/Wii/3DS titles (System Menu, Animal Crossing: City Folk, My
  Pokemon Ranch). A 16-byte header gives the decompressed size and the
  bit offset of the distance-tree bitstream; the two adaptive Huffman
  trees (symbol tree at bit offset 0x0c, distance tree at `ofs_dist`)
  and their LZ-coded payload are a bit-level structure, not something
  Kaitai's byte-oriented model can express, so only the header is
  covered here.

  The distance tree's bit width (11 or 15) is a build-time constant
  baked into the encoder, not stored in the header -- 11 covers System
  Menu / City Folk, 15 covers My Pokemon Ranch; a decoder must try one
  and fall back to the other on failure.
seq:
  - id: magic
    contents: "ASH0"
  - id: len_decompressed_and_flag
    type: u4
    doc: |
      Low 24 bits are the decompressed size; the top byte is unused by
      the decoder here. See `len_decompressed`.
  - id: ofs_dist
    type: u4
    doc: Byte offset of the distance-tree bitstream.
  - id: reserved
    size: 4
  - id: body
    size-eos: true
    doc: |
      Symbol tree (starting at bit offset 0x0c) and distance tree
      (starting at byte offset `ofs_dist`), each followed by their
      LZ-coded stream; bit-packed, not modeled here.
instances:
  len_decompressed:
    value: len_decompressed_and_flag & 0x00ffffff
