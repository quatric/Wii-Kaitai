meta:
  id: sega_gtpa
  title: SEGA GTPA text page table (.gtp)
  file-extension: gtp
  endian: le
doc: |
  SEGA `GTPA` text page table (Sakura Wars: So Long, My Love `*.gtp` and some
  `*.arm`). Record offsets are relative to 0x10; a record runs to the next offset.
  A record is a page layout followed by its text: 24 words of layout data (the
  first words are an id, a length, a style; f32 values at +0x10 are position/size
  such as 180, 640, 448, +0x1C is an RGBA colour, +0x20.. glyph sizes), and from
  +0x60 the NUL-terminated message text ("\n" separates lines).
seq:
  - id: magic
    contents: GTPA
  - id: len_file
    type: u4
  - id: header_size
    type: u4
    doc: 0x10.
  - id: zero
    type: u4
  - id: count
    type: u4
  - id: record_offsets
    type: u4
    repeat: expr
    repeat-expr: count
