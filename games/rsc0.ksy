meta:
  id: rsc0
  title: Purr Pals resource container (.rsc)
  file-extension: rsc
  endian: be
doc: |
  Purr Pals `*.rsc`. Blocks are `{char tag[4], u32 block length incl. header, u32
  name hash, ...}`. Tags: `TEX0` (u32 flags, u16 fmt|mips code 0x17xx = RGBA8 /
  0x18xx = CMPR, u16 w, u16 h, u32 data size, u32 data offset 0x20; mip chain
  follows the top level), `GRP0` (u32 hash, flags, child count, child offset
  0x20, then child blocks), `STR0`, `SND0`, `ANM0`, `MDL0`, `COL0`, `BIN0`,
  `FNT0`.
seq:
  - id: magic
    contents: RSC0
  - id: version
    type: u4
    doc: 2.
  - id: num_blocks
    type: u4
  - id: header_size
    type: u4
    doc: 0x20.
  - id: len_total
    type: u4
  - id: reserved
    size: 12
  - id: blocks
    type: block
    repeat: expr
    repeat-expr: num_blocks
types:
  block:
    seq:
      - id: tag
        type: str
        size: 4
        encoding: ASCII
      - id: len_block
        type: u4
        doc: Includes the header.
      - id: name_hash
        type: u4
      - id: body
        size: len_block - 12
