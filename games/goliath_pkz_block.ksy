meta:
  id: goliath_pkz_block
  title: Goliath "BABEB1B0" block-zlib wrapper (The Amazing Spider-Man .pkz)
  file-extension: pkz
  endian: be
doc: |
  Block-zlib wrapper around the older (v6) Goliath "GS" package, from The
  Amazing Spider-Man on Wii. Each 0x8000-byte-spaced block is an independent
  zlib stream (`78 01`) that carries no final-block bit, so it must be inflated
  to the expected length with a plain inflate (not a strict zlib reader);
  padding after the data is ignored. The concatenated result is a `GS
  version 6.64` chunk tree (`goliath_pkz_v6.ksy`).

  The `ends` table gives the cumulative uncompressed end of each block. A
  second per-0x8000-slice index table follows it; nintoolbox does not need it.
seq:
  - id: magic
    contents: [0xba, 0xbe, 0xb1, 0xb0]
  - id: block_size
    type: u4
    doc: 0x8000.
  - id: data_offset
    type: u4
    doc: 0x8000; first block.
  - id: unknown_0c
    type: u4
  - id: block_count
    type: u4
  - id: file_size
    type: u4
    doc: Compressed total (the file length).
  - id: uncompressed_total
    type: u4
    doc: At most 0x40000000.
  - id: ends
    type: u4
    repeat: expr
    repeat-expr: block_count
    doc: Cumulative uncompressed end of each block.
instances:
  blocks:
    pos: data_offset
    size: block_size
    repeat: expr
    repeat-expr: block_count
    doc: Raw zlib streams, `block_size` bytes apart (the last may be short).
