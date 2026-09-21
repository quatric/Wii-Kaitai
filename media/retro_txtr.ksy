meta:
  id: retro_txtr
  endian: be
  title: Retro Studios old-format TXTR texture (Metroid Prime / DKCR, Wii)
doc: |
  The original Retro Studios "TXTR" texture (Metroid Prime 1-3,
  Donkey Kong Country Returns), per lib-retro-txtr.h. Has no magic of
  its own -- it starts directly with the GX format word. Indexed
  formats (C4/C8/C14X2) carry a palette; pixel data is GX-tiled and
  not detiled here. This covers only the old format; the unrelated
  Tropical Freeze (Wii U) and Metroid Prime Remastered (Switch) TXTR
  revisions are RFRM-wrapped containers documented separately in the
  source and are not modeled here.
seq:
  - id: format
    type: u4
    enum: format_t
    doc: >-
      Retro/GX texture-format ID.  This bare word is not a magic number;
      callers identify the format by validating this ID together with the
      dimensions, mip count, optional palette, and base-level byte count.
  - id: width
    type: u2
    doc: Base mip width in pixels.  The reference parser accepts 1..4096.
  - id: height
    type: u2
    doc: Base mip height in pixels.  The reference parser accepts 1..4096.
  - id: mip_count
    type: u4
    doc: >-
      Number of stored mip levels, including the base level.  The reference
      parser requires 1..11; the payload begins with level 0 and then carries
      any smaller levels consecutively.
  - id: palette_header
    type: palette_header_t
    if: 'format == format_t::c4 or format == format_t::c8 or format == format_t::c14x2'
  - id: pixel_data
    size-eos: true
    doc: >-
      All GX-tiled mip payload bytes.  base_level exposes the exactly-sized
      first level; the remaining bytes hold lower mip levels, whose cumulative
      extent depends on how far the producer continues halving dimensions.
instances:
  pixel_data_offset:
    value: "12 + (format == format_t::c4 or format == format_t::c8 or format == format_t::c14x2 ? 8 + palette_header.palette_byte_size : 0)"
    doc: >-
      Absolute offset of mip level 0: immediately after the 12-byte header
      and, for indexed formats, the 8-byte palette header plus its entries.
  base_level_size:
    value: "format == format_t::i4 or format == format_t::c4 or format == format_t::cmpr ? ((width + 7) / 8) * 8 * ((height + 7) / 8) * 8 / 2 : format == format_t::i8 or format == format_t::ia4 or format == format_t::c8 ? ((width + 7) / 8) * 8 * ((height + 3) / 4) * 4 : format == format_t::rgba8 ? ((width + 3) / 4) * 4 * ((height + 3) / 4) * 4 * 4 : ((width + 3) / 4) * 4 * ((height + 3) / 4) * 4 * 2"
    doc: >-
      Exact byte count of mip level 0 after GX tile rounding.  I4/C4/CMPR
      use 8×8 4-bit tiles; I8/IA4/C8 use 8×4 bytes; IA8/C14X2/RGB565/RGB5A3
      use 4×4 16-bit tiles; and RGBA8 uses 4×4 32-bit tiles.
  base_level:
    pos: pixel_data_offset
    size: base_level_size
    doc: Exact GX-tiled byte range of the base mip level.
types:
  palette_header_t:
    seq:
      - id: pal_format
        type: u4
        enum: pal_format_t
        doc: Encoding of the following 16-bit palette values.
      - id: pal_width
        type: u2
        doc: >-
          Palette width in entries.  This is a u16, not the high half of a
          u32 count; the on-disk palette dimensions multiply to its count.
      - id: pal_height
        type: u2
        doc: Palette height in entries; normally 1 for a conventional CLUT.
      - id: palette
        type: u2
        repeat: expr
        repeat-expr: pal_width * pal_height
        doc: >-
          Big-endian 16-bit palette entries, interpreted according to
          pal_format.  C4, C8 and C14X2 allow at most 16, 256 and 16384
          entries respectively.
    instances:
      palette_count:
        value: pal_width * pal_height
        doc: Total palette entries, derived from the two on-disk dimensions.
      palette_byte_size:
        value: palette_count * 2
        doc: Size of the palette-entry array in bytes.
enums:
  format_t:
    0: i4
    1: i8
    2: ia4
    3: ia8
    4: c4
    5: c8
    6: c14x2
    7: rgb565
    8: rgb5a3
    9: rgba8
    10: cmpr
  pal_format_t:
    0: ia8
    1: rgb565
    2: rgb5a3
