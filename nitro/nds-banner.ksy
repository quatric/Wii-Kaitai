meta:
  id: nds_banner
  endian: le
  title: Nintendo DS ROM banner (icon + titles)
doc: |
  The Nintendo DS ROM banner block ("banner.bin", what the ROM
  header's icon/title offset points at, and what ndstool -b/-t
  extracts), as read by ScanNDSBanner()/IsNDSBanner() in
  lib-nds-banner.c. Ported from GBATEK's "DS Cartridge Icon/Title"
  layout. A 32x32 4bpp icon plus one UTF-16LE title per supported
  language; DSi-enhanced titles (version 0x0103) extend it with an
  8-frame animated icon block.

  There is no format magic; detection instead checks that the stored
  CRC16 (CRC-16/MODBUS, poly 0xa001, init 0xffff) over the region a
  version defines matches.
seq:
  - id: version
    type: u2
    enum: version
  - id: crc16_v1
    type: u2
    doc: CRC16 over 0x0020..0x083f; always present.
  - id: crc16_v2
    type: u2
    doc: CRC16 over 0x0020..0x093f; meaningful for version >= 2.
  - id: crc16_v3
    type: u2
    doc: CRC16 over 0x0020..0x0a3f; meaningful for version >= 3.
  - id: crc16_dsi
    type: u2
    doc: CRC16 over 0x1240..0x23bf; meaningful for version 0x103.
  - id: reserved1
    size: 0x16
  - id: icon_bitmap
    size: 0x200
    doc: 32x32 icon, 4bpp, 8x8 tiles, 4 tiles per row.
  - id: icon_palette
    type: bgr555
    repeat: expr
    repeat-expr: 16
    doc: 16 x BGR555; entry 0 is the transparent color.
  - id: titles
    type: title_block
    repeat: expr
    repeat-expr: 8
    doc: One 0x100-byte UTF-16LE title block per NDS_BANNER_LANG_* slot.
  - id: reserved2
    size: 0x800
  - id: dsi_bitmaps
    type: dsi_bitmap
    repeat: expr
    repeat-expr: 8
    if: version == version::dsi_animated
  - id: dsi_palettes
    type: dsi_palette
    repeat: expr
    repeat-expr: 8
    if: version == version::dsi_animated
  - id: dsi_animation
    type: anim_token
    repeat: expr
    repeat-expr: 64
    if: version == version::dsi_animated
types:
  bgr555:
    seq:
      - id: raw
        type: u2
  title_block:
    seq:
      - id: title_utf16le
        size: 0x100
        doc: NUL-terminated UTF-16LE, up to 3 newline-separated lines.
  dsi_bitmap:
    seq:
      - id: bitmap
        size: 0x200
  dsi_palette:
    seq:
      - id: colors
        type: bgr555
        repeat: expr
        repeat-expr: 16
  anim_token:
    doc: |
      One animation step; a `duration` of 0 terminates the sequence
      (DecodeNDSBannerIcon_RGBA()'s nds_banner_frame_t).
    seq:
      - id: duration
        type: u1
        doc: In 1/60 s units; 0 ends the sequence.
      - id: flags
        type: u1
    instances:
      bitmap_index:
        value: flags & 7
      palette_index:
        value: (flags >> 3) & 7
      flip_h:
        value: (flags & 0x40) != 0
      flip_v:
        value: (flags & 0x80) != 0
enums:
  version:
    1: v1
    2: v2
    3: v3
    0x103: dsi_animated
