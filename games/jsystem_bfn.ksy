meta:
  id: jsystem_bfn
  title: JSystem resource font (.bfn)
  file-extension: bfn
  endian: be
doc: |
  JSystem resource font (`FONTbfn1`; Twilight Princess, Super Mario Galaxy,
  Pikmin 2 and other JUT games). Blocks: `INF1` (font type, ascent, descent,
  width, leading), `WID1`, `GLY1` (glyph texture pages: first/last code, cell
  size, GX texture format I4/I8/IA4/IA8, rows x columns of cells, page size) and
  `MAP1`.
seq:
  - id: magic
    contents: FONTbfn1
  - id: len_file
    type: u4
  - id: num_blocks
    type: u4
  - id: reserved
    size: 0x10
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
        doc: Includes the 8-byte block header.
      - id: body
        size: len_block - 8
