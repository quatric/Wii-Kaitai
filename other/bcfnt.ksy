meta:
  id: bcfnt
  file-extension: bcfnt
  title: CTR/Cafe BCFNT/BFFNT bitmap font
doc: |
  The 3DS (`CFNT`, little-endian) / Wii U (`FFNT`, big-endian) sibling of
  NW4R's BRFNT bitmap font (see `nw4r/brfnt.ksy`): glyphs baked into
  texture sheets (`TGLP`), a char-width table (`CWDH`) and a code-to-glyph
  map (`CMAP`), chained off a `FINF` block. Endianness follows a
  byte-order mark right after the magic, exactly like SARC/BFRES/BARS.
  Section pointers in `FINF`/`CWDH`/`CMAP` are absolute file offsets to
  the section *body*, 8 bytes past that section's own tag+size header --
  the same convention BRFNT uses.
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
    doc: '"CFNT" (3DS) or "FFNT" (Wii U).'
  - id: bom
    type: u2be
    doc: 0xfeff for big-endian (Wii U) content, 0xfffe for little-endian (3DS).
  - id: content
    type:
      switch-on: bom
      cases:
        0xfeff: body(false)
        0xfffe: body(true)
types:
  body:
    params:
      - id: is_le
        type: bool
    meta:
      endian:
        switch-on: is_le
        cases:
          true: le
          false: be
    seq:
      - id: len_header
        type: u2
      - id: version
        type: u4
        doc: 0x03000000 for CFNT, 0x04000000 for FFNT.
      - id: len_file
        type: u4
      - id: num_sections
        type: u2
      - id: reserved
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
        seq:
          - id: font_type
            type: u1
          - id: line_feed
            type: u1
          - id: alter_char_index
            type: u2
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
            doc: CTR/Cafe texture format; 0 seen for RGBA8 from this repo's encoder.
          - id: num_rows
            type: u2
          - id: num_columns
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
        seq:
          - id: first_index
            type: u2
          - id: last_index
            type: u2
          - id: ofs_next
            type: u4
          - id: widths
            type: char_width
            repeat: expr
            repeat-expr: last_index - first_index + 1
      char_width:
        seq:
          - id: left
            type: s1
          - id: glyph_width
            type: u1
          - id: char_width
            type: u1
      char_map:
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
          - id: table
            type: u2
            repeat: expr
            repeat-expr: code_end - code_begin + 1
            if: mapping_type == cmap_type::table
          - id: num_scan
            type: u2
            if: mapping_type == cmap_type::scan
          - id: scan
            type: scan_entry
            repeat: expr
            repeat-expr: num_scan
            if: mapping_type == cmap_type::scan
      scan_entry:
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
