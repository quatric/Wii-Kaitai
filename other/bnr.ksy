meta:
  id: bnr
  file-extension: bnr
  endian: be
  title: GameCube/Wii BNR disc banner
doc: |
  The disc-launcher banner every GameCube and Wii title carries: a 96x32
  RGB5A3 icon plus, for BNR2, up to six language blocks of Shift-JIS
  title/subtitle/description text. `BNR1` is the GameCube (single-language)
  variant; `BNR2` is the Wii (six-language) variant that follows it under
  the same 0x20-byte header and pixel layout, just with a bigger comment
  table after the icon.

  Layout taken from lib-bnr.c's `DecodeBNR_RGBA`/`EncodeBNR_RGBA`, which
  only round-trip the fixed 96x32 RGB5A3 icon: the 0x20-byte header ahead of
  it and the comment table behind it are treated as opaque padding there,
  so this definition exposes the icon precisely and the comment area as raw
  bytes only, sized from each magic's known total file length.
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
    valid:
      any-of: ['"BNR1"', '"BNR2"']
    doc: '`BNR1` (GameCube, one language) or `BNR2` (Wii, six languages).'
  - id: reserved
    size: 0x1c
    doc: |
      Padding between the magic and the icon pixels; the total header is
      0x20 bytes. Not otherwise interpreted by lib-bnr.c.
  - id: icon
    type: icon_pixel
    repeat: expr
    repeat-expr: 96 * 32
    doc: |
      96x32 RGB5A3 texels, stored 4x4-pixel-tiled (GX `CMPR`-style block
      order): tiles run left-to-right/top-to-bottom, and within each tile
      pixels also run left-to-right/top-to-bottom.
  - id: comments
    size-eos: true
    doc: |
      One 0x140-byte Shift-JIS comment block (game name / developer /
      full title / full developer / description, NUL-padded) for BNR1, or
      six such blocks (one per Wii system language) for BNR2. Not decoded
      here -- lib-bnr.c never reads this area, only the icon.
types:
  icon_pixel:
    seq:
      - id: raw
        type: u2
    instances:
      is_opaque:
        value: (raw & 0x8000) != 0
        doc: Bit 15 set selects RGB5 with full alpha; clear selects IA4-style RGBA4.
      r:
        value: 'is_opaque ? (raw >> 10 & 0x1f) * 255 / 31 : (raw >> 8 & 0xf) * 17'
      g:
        value: 'is_opaque ? (raw >> 5 & 0x1f) * 255 / 31 : (raw >> 4 & 0xf) * 17'
      b:
        value: 'is_opaque ? (raw & 0x1f) * 255 / 31 : (raw & 0xf) * 17'
      a:
        value: 'is_opaque ? 255 : (raw >> 12 & 7) * 255 / 7'
