meta:
  id: midway_fnt
  title: Midway bitmap font metrics (.fnt)
  file-extension: fnt
  endian: be
doc: |
  Midway bitmap font metrics (members of TNA Impact! `.WAD` packs, see
  `midway_wad`). A 256-byte character -> glyph index map follows at 0x20 (index
  1 for unmapped), then the font name, then 20-byte glyph records. The atlas is
  the sibling `.tim` (see `midway_tim`).
seq:
  - id: reserved0
    size: 0x0c
  - id: cell_height
    type: u2
  - id: line_height
    type: u2
  - id: reserved1
    size: 4
  - id: name_offset
    type: u4
    doc: 0x120.
  - id: glyph_table_offset
    type: u4
    doc: 0x134.
  - id: reserved2
    size: 4
  - id: char_to_glyph
    size: 256
instances:
  name:
    pos: name_offset
    type: strz
    encoding: ASCII
types:
  glyph:
    seq:
      - id: u0
        type: f4
      - id: v0
        type: f4
      - id: u1
        type: f4
      - id: v1
        type: f4
      - id: advance
        type: u1
      - id: pad
        size: 3
