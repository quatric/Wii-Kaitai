meta:
  id: wii_imet
  endian: be
  title: Wii channel banner IMET header
doc: |
  Wii channel banner IMET header, per lib-wii-banner.h. Magic sits
  at a fixed offset from the start of this structure regardless of
  the leading padding scheme the caller stripped (0x40 for a disc
  /opening.bnr, 0 for the rare unpadded variant, 0x80 for a NAND
  content's 00000000.app); this definition starts right at the
  magic. The embedded U8 archive begins immediately after the fixed
  0x600-byte header.
seq:
  - id: magic
    contents: "IMET"
  - id: unknown_04
    size: 0xc
  - id: header_size
    type: u4
    doc: Normally IMET_SIZE (0x600).
  - id: icon_size
    type: u4
  - id: banner_size
    type: u4
  - id: sound_size
    type: u4
  - id: unknown_28
    size: 4
  - id: titles
    type: str
    size: 0x54
    encoding: UTF-16BE
    repeat: expr
    repeat-expr: 10
    doc: Wii menu language order (not the SMDH or NDS banner order).
  - id: unknown_after_titles
    size-eos: true
