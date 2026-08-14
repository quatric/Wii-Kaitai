meta:
  id: brfnt
  file-extension: brfnt
  endian: be
  title: NW4R BRFNT bitmap font
doc: |
  A pre-rendered bitmap font: glyphs baked into GX texture sheets, plus
  the tables that map a character code to a cell and give it a width.
  Magic `RFNT`.

  Rendering one character takes all four section types. `CMAP` turns the
  code into a glyph index, `CWDH` gives that index its advance widths, and
  `TGLP` says which sheet the index lands on and where in the grid --
  sheet `index / (rows * columns)`, then row and column within it.

  Every offset in this format is an **absolute file offset**, and each one
  points at a section's *body* rather than its tag: `FINF.ofs_tglp` on the
  sample font reads 56 while the `TGLP` section itself begins at 48. The
  same +8 applies to `CWDH.ofs_next` and `CMAP.ofs_next`, which is how the
  chained sections are walked.
seq:
  - id: magic
    contents: "RFNT"
  - id: bom
    type: u2
  - id: version
    type: u2
    doc: 0x104 across the sample fonts.
  - id: len_file
    type: u4
  - id: len_header
    type: u2
  - id: num_sections
    type: u2
  - id: sections
    type: section
    repeat: expr
    repeat-expr: num_sections
types:
  section:
    seq:
      - id: magic
        type: str
        size: 4
        encoding: ASCII
      - id: len_section
        type: u4
      - id: body
        size: len_section - 8
        type:
          switch-on: magic
          cases:
            '"FINF"': font_info
            '"TGLP"': texture_glyph
            '"CWDH"': char_widths
            '"CMAP"': char_map

  font_info:
    doc: |
      `FINF`. The three offsets are absolute and point at section bodies,
      so the first `CWDH` and `CMAP` are reachable from here without
      walking the section list.
    seq:
      - id: font_type
        type: u1
      - id: line_feed
        type: u1
        doc: Baseline-to-baseline distance in pixels.
      - id: alter_char_index
        type: u2
        doc: Glyph index substituted for any code the maps do not cover.
      - id: default_left
        type: s1
      - id: default_glyph_width
        type: u1
      - id: default_char_width
        type: u1
      - id: encoding
        type: u1
      - id: ofs_tglp
        type: u4
      - id: ofs_cwdh
        type: u4
      - id: ofs_cmap
        type: u4
      - id: height
        type: u1
      - id: width
        type: u1
      - id: ascent
        type: u1
      - id: descent
        type: u1

  texture_glyph:
    doc: |
      `TGLP`. Glyphs are packed into a grid on each sheet; the sheets
      themselves are ordinary GX textures in `sheet_format`, sharing the
      encoding enum with TEX0. The sample font carries 334 sheets of 8 KiB
      each and `ofs_sheet_data` lands exactly `num_sheets * len_sheet`
      bytes before the end of the section.
    seq:
      - id: cell_width
        type: u1
      - id: cell_height
        type: u1
      - id: baseline_position
        type: u1
      - id: max_char_width
        type: u1
      - id: len_sheet
        type: u4
      - id: num_sheets
        type: u2
      - id: sheet_format
        type: u2
        enum: gx_texture_format
      - id: num_columns
        type: u2
      - id: num_rows
        type: u2
      - id: sheet_width
        type: u2
      - id: sheet_height
        type: u2
      - id: ofs_sheet_data
        type: u4
    instances:
      sheets:
        io: _root._io
        pos: ofs_sheet_data
        size: len_sheet
        repeat: expr
        repeat-expr: num_sheets

  char_widths:
    doc: |
      `CWDH`. Covers the inclusive glyph-index range `first_index` to
      `last_index`; a font with more glyphs than one block chains further
      blocks through `ofs_next`.
    seq:
      - id: first_index
        type: u2
      - id: last_index
        type: u2
      - id: ofs_next
        type: u4
        doc: Absolute offset to the next CWDH body, or 0 at the end of the chain.
      - id: widths
        type: char_width
        repeat: expr
        repeat-expr: last_index - first_index + 1

  char_width:
    seq:
      - id: left
        type: s1
        doc: Left-side bearing; signed, so a glyph may start left of the pen.
      - id: glyph_width
        type: u1
        doc: Inked width.
      - id: char_width
        type: u1
        doc: Advance to the next pen position.

  char_map:
    doc: |
      `CMAP`. Maps character codes to glyph indices over the inclusive
      range `code_begin`..`code_end`, in one of three encodings chosen per
      block -- a font mixes them, using the cheap `direct` form for a
      contiguous ASCII run and `scan` for a sparse CJK tail. All three
      appear in the sample font.
    seq:
      - id: code_begin
        type: u2
      - id: code_end
        type: u2
      - id: mapping_type
        type: u2
        enum: cmap_type
      - id: reserved
        type: u2
      - id: ofs_next
        type: u4
      - id: direct_base
        type: u2
        if: mapping_type == cmap_type::direct
        doc: |
          Glyph index of `code_begin`; the rest of the range follows
          consecutively, so index = base + (code - code_begin).
      - id: table
        type: u2
        repeat: expr
        repeat-expr: code_end - code_begin + 1
        if: mapping_type == cmap_type::table
        doc: One glyph index per code in the range; 0xffff for unmapped.
      - id: num_scan
        type: u2
        if: mapping_type == cmap_type::scan
      - id: scan
        type: scan_entry
        repeat: expr
        repeat-expr: num_scan
        if: mapping_type == cmap_type::scan

  scan_entry:
    doc: An explicit code-to-index pair, for ranges too sparse to tabulate.
    seq:
      - id: code
        type: u2
      - id: index
        type: u2
enums:
  cmap_type:
    0: direct
    1: table
    2: scan
  gx_texture_format:
    0: i4
    1: i8
    2: ia4
    3: ia8
    4: rgb565
    5: rgb5a3
    6: rgba8
    8: ci4
    9: ci8
    10: ci14x2
    14: cmpr
