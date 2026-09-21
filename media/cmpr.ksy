meta:
  id: cmpr
  title: Nintendo GameCube/Wii CMPR compressed texture block
  endian: be
doc: |
  `CMPR` is not a standalone file format with its own header; it is the
  block-compressed *pixel data* format used inside GameCube/Wii texture
  containers (TPL, BTI/BREFT and friends, `IMG_CMPR` in this codebase's
  image code) whenever a texture's format byte selects CMPR. There is no
  magic number or container to model -- only the fixed layout of the
  compressed texel data itself, which is why this .ksy models a single
  "CMPR image" as a 2D grid of 8x8-pixel macro-blocks rather than a file.

  It is Nintendo's own tiling of a DXT1-style S3TC codec: each 8x8 pixel
  macro-block is split into four 4x4 sub-blocks (top-left, top-right,
  bottom-left, bottom-right), and each 4x4 sub-block is one ordinary
  DXT1 block: two RGB565 endpoint colors (`color0`, `color1`) followed
  by sixteen 2-bit indices (packed as four bytes, four indices per byte,
  most-significant pair first) selecting between `color0`, `color1`, and
  two derived colors. Which two colors are derived, and whether index 3
  means "fully transparent" or a third interpolated color, depends on
  whether `color0`'s raw u16 value is greater than `color1`'s (mirrors
  interpretation of the color1/color0 order) -- see `conv_from_CMPR()` in
  lib-cmpr.c for the exact derivation and `CMPR_close_info()` for the
  inverse (encoder) side.

  Macro-blocks are stored row-major, left to right then top to bottom,
  covering an image whose width/height are rounded up to a multiple of 8.
seq:
  - id: macro_blocks
    type: macro_block
    repeat: eos
types:
  macro_block:
    doc: One 8x8-pixel block, stored as four 4x4 DXT1-style sub-blocks in TL/TR/BL/BR order.
    seq:
      - id: sub_blocks
        type: dxt1_sub_block
        repeat: expr
        repeat-expr: 4
  dxt1_sub_block:
    doc: One 4x4-pixel DXT1-style block.
    seq:
      - id: color0
        type: u2
        doc: RGB565 endpoint color, packed 5 bits red / 6 bits green / 5 bits blue.
      - id: color1
        type: u2
        doc: RGB565 endpoint color, packed 5 bits red / 6 bits green / 5 bits blue.
      - id: indices
        type: u1
        repeat: expr
        repeat-expr: 4
        doc: |
          Sixteen 2-bit palette indices, four per byte (rows of the 4x4
          block), most-significant 2 bits = leftmost pixel of the row.
