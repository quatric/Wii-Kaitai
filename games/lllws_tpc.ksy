meta:
  id: lllws_tpc
  title: Little League World Series Baseball 2009 texture pack (.tpc)
  file-extension: tpc
  endian: be
doc: |
  Little League World Series Baseball 2009 `*.tpc` texture pack (Wii). Textures
  are GX images; formats CI4 (8), CI8 (9), RGB565 (4), RGB5A3 (5) and RGBA8 (6)
  are decoded by nintoolbox. Entries are 32 bytes; the last four bytes are not
  documented in nintoolbox's parser and are left unmodelled.
seq:
  - id: zero
    type: u1
  - id: num_entries
    type: u1
  - id: zero2
    type: u2
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: texture_offset
        type: u4
      - id: palette_offset
        type: u4
      - id: height
        type: u2
      - id: width
        type: u2
      - id: ones
        size: 4
        doc: 01 01 01 01.
      - id: zero0
        type: u4
      - id: zero1
        size: 3
      - id: gx_format
        type: u1
      - id: num_palette_entries
        type: u2
      - id: palette_format
        type: u2
        enum: palette_format
      - id: trailing
        size: 4
enums:
  palette_format:
    0: ia8
    1: rgb565
    2: rgb5a3
