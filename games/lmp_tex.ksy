meta:
  id: lmp_tex
  title: Jillian Michaels Fitness Ultimatum texture lump (.lmp)
  file-extension: lmp
  endian: be
doc: |
  Jillian Michaels' Fitness Ultimatum (Wii) `resfbc_wii/*.lmp` texture lumps
  (the sibling `.lps` is an XML build manifest). Per entry a 0x80-byte header
  plus GX pixel data; the header stores width and height as big-endian u16 at
  +0/+2 and a format word at +6 (0x8080 = GX RGBA8, 0x0004 = GX CMPR, a single
  level). Names are NUL-terminated (`*.tex`).
seq:
  - id: count
    type: u2
  - id: one
    type: u2
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: zero0
        type: u4
      - id: name_offset
        type: u4
      - id: zero1
        type: u4
      - id: data_offset
        type: u4
      - id: len_data
        type: u4
      - id: zero2
        type: u4
    instances:
      name:
        pos: name_offset
        io: _root._io
        type: strz
        encoding: ASCII
