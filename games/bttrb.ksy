meta:
  id: bttrb
  file-extension: trb
  endian: be
  title: Blue Tongue "TRB" data package (de Blob 2, Wii)
doc: |
  A section-table archive Blue Tongue's Toshi engine uses on the Wii disc
  of de Blob 2 (`TRB\0`), laid out by hand in `lib-bttrb.h`'s header
  comment against that disc. Earlier and later Toshi games use the
  unrelated TSFB/TRBF layout of `lib-toshi`, which this definition does
  not cover.

  A section holds either raw engine data or the shared string table
  (section 0, `.text`); symbols right after the sections index into a
  section by name and, for the `tcmd`/`ttex` tags, describe a model or
  texture object living inside the `.data`/`gpu_data`/`__s00000`
  sections. Only the section and symbol tables are modeled here -- the
  `tcmd`/`ttex` object layouts are `lib-bttrb.c`'s job, not Kaitai's,
  since they are addressed relative to specific named sections rather
  than the file directly.
seq:
  - id: magic
    contents: "TRB\0"
  - id: unknown1
    contents: [0x00, 0x00, 0x07, 0xd1]
  - id: unknown2
    type: u4
    doc: Always 2 in the de Blob 2 sample.
  - id: num_sections
    type: u4
  - id: len_sections
    type: u4
    doc: '`0x30 * num_sections`.'
  - id: num_symbols
    type: u4
  - id: unknown3
    size: 0x1c
    doc: Trailing header bytes before the section table at absolute 0x80.
instances:
  sections:
    pos: 0x80
    type: section
    repeat: expr
    repeat-expr: num_sections
  symbols:
    pos: 0x80 + len_sections
    type: symbol
    repeat: expr
    repeat-expr: num_symbols
types:
  section:
    doc: |
      One 0x30-byte section record. Section 0 (`.text`) is the string
      table `name_off` indexes into; the rest are named engine data
      blocks (`.data`, `__s00000` the pixel pool, `gpu_data` GX vertex
      data, `model_collision`, `XUR` an embedded Xbox UI scene, and
      other engine tables).
    seq:
      - id: unknown1
        type: u4
      - id: name_off
        type: u4
        doc: Offset of this section's name in section 0's string table.
      - id: unknown2
        type: u4
      - id: flags
        type: u4
      - id: len_section
        type: u4
      - id: len_section2
        type: u4
      - id: file_off
        type: u4
        doc: Absolute file offset, 0x800-aligned.
      - id: reserved
        type: u4
        repeat: expr
        repeat-expr: 5
    instances:
      body:
        io: _root._io
        pos: file_off
        size: len_section
        if: len_section > 0

  symbol:
    doc: 16-byte symbol record right after the section table.
    seq:
      - id: tag
        type: u4
        doc: Four-character tag stored as a big-endian u32, e.g. `tcmd`, `ttex`.
      - id: section_offset
        type: u4
        doc: Offset of this symbol's data within its section.
      - id: section_index_shifted
        type: u4
        doc: Section index, shifted left 16 bits.
      - id: name_off
        type: u4
        doc: Offset of this symbol's name in section 0's string table.
    instances:
      section_index:
        value: section_index_shifted >> 16
