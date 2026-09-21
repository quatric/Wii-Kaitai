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
  - id: width
    type: u2
  - id: height
    type: u2
  - id: mip_count
    type: u4
  - id: palette_header
    type: palette_header_t
    if: 'format == format_t::c4 or format == format_t::c8 or format == format_t::c14x2'
  - id: pixel_data
    size-eos: true
types:
  palette_header_t:
    seq:
      - id: pal_format
        type: u4
        enum: pal_format_t
      - id: pal_count
        type: u4
      - id: palette
        type: u2
        repeat: expr
        repeat-expr: pal_count
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
