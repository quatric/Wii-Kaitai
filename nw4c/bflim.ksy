meta:
  id: bflim
  file-extension: bflim
  endian: le
  title: NintendoWare BFLIM image
doc: |
  A single texture as used by BFLYT layouts. Unusually, the header is at
  the **end** of the file: the image data starts at offset 0 and the
  40-byte `FLIM` + `imag` trailer follows it, so a BFLIM opens with
  whatever its first texels happen to be and identifying one by its first
  four bytes fails.

  Texels are in the 3DS's tiled order, not scanline order, and the image
  is padded out to power-of-two dimensions -- `width` and `height` are the
  logical size, while the stored data covers the padded one. That padding
  is how `format` was confirmed here rather than taken on trust: dividing
  `len_data` by the padded pixel count gives exactly 8 bits per pixel for
  L8, A8 and LA4, 16 for LA8, RGB565 and RGBA4, 32 for RGBA8, and 4 for
  L4, A4 and ETC1, across all 667 samples.

  BFLIM is the 3DS/NW4C texture format referenced by a BFLYT `txl1`
  entry (`nw4c/bflyt.ksy`). Its Wii U/NW4F counterpart is a texture
  wrapped directly in GX2 surface form (see `nw4c/gtx.ksy`) rather than a
  separate tiled-PICA200 file, so unlike BFLYT/BFLAN this format does not
  carry over unchanged to the Wii U generation -- it is 3DS-specific.
instances:
  header:
    pos: _io.size - 0x28
    type: flim_header
    doc: |
      The trailer, at a fixed 40 bytes from the end. `len_file` there
      matches the real file length and `image.len_data` matches
      `len_file - 0x28` in every sample, so either one independently
      confirms where the split lies.
  data:
    pos: 0
    size: _io.size - 0x28
    doc: Tiled texel data in `header.image.format`.
types:
  flim_header:
    seq:
      - id: magic
        contents: "FLIM"
      - id: bom
        type: u2
      - id: len_header
        type: u2
        doc: 0x14.
      - id: version
        type: u4
        doc: 0x07020100 across all samples -- the same value BFLYT and BFLAN carry.
      - id: len_file
        type: u4
      - id: num_blocks
        type: u2
        doc: 1 in every sample; the only block is `imag`.
      - id: reserved
        type: u2
      - id: image
        type: image_block

  image_block:
    seq:
      - id: magic
        contents: "imag"
      - id: len_block
        type: u4
        doc: 0x10.
      - id: width
        type: u2
      - id: height
        type: u2
        doc: |
          Logical size. The stored data covers both dimensions rounded up
          to a power of two, minimum 8.
      - id: alignment
        type: u2
      - id: format
        type: u1
        enum: image_format
        doc: |
          Values 0-3, 5 and 8-13 are confirmed by the bits-per-pixel check
          described at the top of this file. 4 (hilo8), 6 (rgb8), 7
          (rgba5551) and 14 do not occur in the sample set; those names
          come from published tooling rather than from measurement here.
      - id: swizzle
        type: u1
        doc: |
          4 for every linear format in the samples and 8 for both ETC1
          ones, so it tracks the block layout rather than the colour
          layout.
      - id: len_data
        type: u4
enums:
  image_format:
    0: l8
    1: a8
    2: la4
    3: la8
    4: hilo8
    5: rgb565
    6: rgb8
    7: rgba5551
    8: rgba4
    9: rgba8
    10: etc1
    11: etc1a4
    12: l4
    13: a4
    14: etc1_alt
