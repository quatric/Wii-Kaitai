meta:
  id: nutexb
  file-extension: nutexb
  endian: le
  title: Namco Switch texture (NUTEXB)
doc: |
  Nintendo Switch block-linear texture used by Namco titles (Smash
  Ultimate, Paper Mario). The header/trailer sits at the *end* of the
  file: a 0x70-byte footer whose last 3 bytes are "XET" (the tail of
  "NUTEXB" reversed... in practice the reader just checks the last 3
  bytes equal "XET"), preceded by a 64-byte name field and, before that,
  the raw block-linear pixel data.

  Reference: nintoolbox project/src/lib-nutexb.c (DecodeNUTEXB_RGBA /
  EncodeNUTEXB_RGBA).
seq:
  - id: image_data
    size: _io.size - 0x70
    doc: Block-linear tiled pixel data (GOB-tiled, per `mip_offsets`/`block_height_log2` semantics of the BNTX tiling scheme).
  - id: mip_offsets
    doc: Per-mip byte offsets into `image_data`; only the first is used by the reader.
    size: 0x40
  - id: footer
    type: footer_tail
types:
  footer_tail:
    doc: |
      Trailing 0x30-byte fixed record. `width`/`height`/`format`/
      `mip_count`/`len_image` are the fields the reader actually uses;
      the rest are unknown/reserved. Ends with a 1-byte pad, the "XET"
      tag and a u4 version, the last byte of which is the file's final byte.
    seq:
      - id: unk_00
        type: u4
      - id: width
        type: u4
      - id: height
        type: u4
      - id: unk_0c
        type: u4
      - id: format
        type: u2
        enum: nutexb_format
      - id: unk_12
        type: u2
      - id: unk_14
        type: u4
      - id: mip_count
        type: u4
      - id: unk_1c
        type: u4
      - id: unk_20
        type: u4
      - id: len_image
        type: u4
      - id: pad_zero
        type: u1
      - id: tag
        type: str
        size: 3
        encoding: ASCII
        valid: '"XET"'
      - id: version
        type: u4
enums:
  nutexb_format:
    0x0400: r8g8b8a8_unorm
    0x0405: r8g8b8a8_srgb
    0x0450: b8g8r8a8_unorm
    0x0455: b8g8r8a8_srgb
    0x0480: bc1_unorm
    0x0485: bc1_srgb
    0x0490: bc2_unorm
    0x0495: bc2_srgb
    0x04a0: bc3_unorm
    0x04a5: bc3_srgb
    0x0180: bc4_unorm
    0x0185: bc4_snorm
    0x0280: bc5_unorm
    0x0285: bc5_snorm
    0x04d7: bc6_ufloat
    0x04d8: bc6_sfloat
    0x04e0: bc7_unorm
    0x04e5: bc7_srgb
    0x0434: r32g32b32a32_float
