meta:
  id: tpl
  endian: be
  title: Nintendo GameCube/Wii TPL texture palette library
doc: |
  Nintendo GameCube/Wii TPL texture library, per `tpl_header_t`/
  `tpl_header_ex_t`/`tpl_imgtab_t`/`tpl_pal_header_t`/
  `tpl_img_header_t` in lib-image.h. GX-tiled pixel data itself is
  not detiled here.
seq:
  - id: magic
    contents: [0x00, 0x20, 0xaf, 0x30]
    doc: TPL container signature (big-endian 0x0020af30).
  - id: num_images
    type: u4
    doc: Number of independent image-table entries in this library.
  - id: imgtab_offset
    type: u4
    doc: >-
      Absolute file offset of the num_images × 8-byte image table.  Every
      image and palette reference in that table is also file-relative.
instances:
  extended_magic:
    pos: 12
    type: u4
    doc: >-
      Candidate TPLx marker at offset 0x0c.  It is inspected out-of-line so
      ordinary 0x0c-byte TPL headers do not have to reserve an extended
      header in their sequential layout.
  is_ex:
    value: imgtab_offset >= 28 and extended_magic == 0x54504c78
    doc: >-
      True only for Wiimm's TPLx extension: both the `TPLx` marker and an
      image table beginning after the 0x1c-byte extended header are required.
  extended_width:
    pos: 16
    type: u4
    if: is_ex
    doc: >-
      TPLx display width.  Unlike image_header.width this can describe the
      intended icon canvas rather than the tiled texture's storage width.
  extended_height:
    pos: 20
    type: u4
    if: is_ex
    doc: TPLx display height, paired with extended_width.
  extended_icon_count:
    pos: 24
    type: u4
    if: is_ex
    doc: Number of logical icons described by a TPLx container.
  image_table:
    type: imgtab_entry
    repeat: expr
    repeat-expr: num_images
    pos: imgtab_offset
    doc: Directory of image-header and optional palette-header pointers.
types:
  imgtab_entry:
    seq:
      - id: image_offset
        type: u4
        doc: Absolute offset of the 0x24-byte image header for this entry.
      - id: palette_offset
        type: u4
        doc: >-
          Absolute offset of this entry's 0x0c-byte palette header, or zero
          when the image format does not use an external palette.
    instances:
      image_header:
        pos: image_offset
        type: img_header_t
        io: _root._io
        doc: Resolved image header at image_offset.
      palette_header:
        pos: palette_offset
        type: pal_header_t
        io: _root._io
        if: palette_offset != 0
        doc: Resolved palette header when palette_offset is non-zero.
  img_header_t:
    seq:
      - id: height
        type: u2
        doc: Stored image height in pixels, before any TPLx canvas override.
      - id: width
        type: u2
        doc: Stored image width in pixels, before any TPLx canvas override.
      - id: image_format
        type: u4
        doc: >-
          GX texture format code.  It determines tiled pixel decoding and,
          for CI formats, requires the linked palette header.
      - id: data_offset
        type: u4
        doc: Absolute file offset of the GX-tiled pixel data.
      - id: wrap_s
        type: u4
        doc: Horizontal texture-coordinate wrapping mode (normally 0 or 1).
      - id: wrap_t
        type: u4
        doc: Vertical texture-coordinate wrapping mode (normally 0 or 1).
      - id: min_filter
        type: u4
        doc: GX minification-filter value; nintoolbox-generated TPLs use 1.
      - id: mag_filter
        type: u4
        doc: GX magnification-filter value; nintoolbox-generated TPLs use 1.
      - id: load_bias
        type: f4
        doc: LOD bias value; nintoolbox-generated TPLs use 0.0.
      - id: edge_load
        type: u1
        doc: GX LOD/edge-load setting; normally zero in TPL files.
      - id: min_load
        type: u1
        doc: Minimum loaded mip level; normally zero in TPL files.
      - id: max_load
        type: u1
        doc: Maximum loaded mip level; normally zero in TPL files.
      - id: unpacked
        type: u1
        doc: GX texture-header unpacked flag; normally zero in TPL files.
    instances:
      data:
        pos: data_offset
        size-eos: true
        io: _root._io
        doc: >-
          Bytes from data_offset to end of the containing stream.  This is a
          navigational view, not an exact texture allocation: TPL data blocks
          can be out of order and their GX-tiled extent depends on format,
          dimensions, and mip-level layout.
  pal_header_t:
    seq:
      - id: num_entries
        type: u2
        doc: Number of 16-bit palette entries.
      - id: unknown1
        type: u2
        doc: Reserved/unknown 16-bit palette-header field; preserve it.
      - id: palette_format
        type: u4
        doc: GX palette format code (the entries are normally 16-bit colors).
      - id: data_offset
        type: u4
        doc: Absolute file offset of the palette-entry array.
    instances:
      data:
        pos: data_offset
        size: num_entries * 2
        io: _root._io
        doc: >-
          The exact palette storage: num_entries consecutive 16-bit GX
          palette values.  Interpretation is selected by palette_format.
