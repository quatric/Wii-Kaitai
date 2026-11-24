meta:
  id: okami_t
  title: Clover Okami texture file (.t)
  file-extension: t
  endian: be
doc: |
  Clover / Okami (Wii) `.t` texture file: the body of an IDD `TEX` section on
  its own. A texture record is `{u16 height, u16 width (swapped against IDD),
  u32 GX format, u32 pixel data offset}`; a palette header is `{u32 entries <<
  16, u32 TLUT format, u32 offset}`. All offsets are from the start of the file.
seq:
  - id: id
    type: u4
  - id: count
    type: u4
  - id: table_offset
    type: u4
    doc: 0xc.
  - id: pairs
    type: pair
    repeat: expr
    repeat-expr: count
types:
  pair:
    seq:
      - id: texture_record_offset
        type: u4
      - id: palette_header_offset
        type: u4
        doc: 0 = none.
    instances:
      texture:
        pos: texture_record_offset
        io: _root._io
        type: texture_record
      palette:
        pos: palette_header_offset
        io: _root._io
        type: palette_header
        if: palette_header_offset != 0
  texture_record:
    seq:
      - id: height
        type: u2
      - id: width
        type: u2
      - id: gx_format
        type: u4
      - id: pixel_data_offset
        type: u4
  palette_header:
    seq:
      - id: num_entries_shl_16
        type: u4
      - id: tlut_format
        type: u4
        doc: 0 IA8, 1 RGB565, 2 RGB5A3.
      - id: offset
        type: u4
