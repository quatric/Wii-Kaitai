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
  - id: num_images
    type: u4
  - id: imgtab_offset
    type: u4
instances:
  is_ex:
    value: imgtab_offset >= 28
  image_table:
    type: imgtab_entry
    repeat: expr
    repeat-expr: num_images
    pos: imgtab_offset
types:
  imgtab_entry:
    seq:
      - id: image_offset
        type: u4
      - id: palette_offset
        type: u4
    instances:
      image_header:
        pos: image_offset
        type: img_header_t
        io: _root._io
      palette_header:
        pos: palette_offset
        type: pal_header_t
        io: _root._io
        if: palette_offset != 0
  img_header_t:
    seq:
      - id: height
        type: u2
      - id: width
        type: u2
      - id: image_format
        type: u4
      - id: data_offset
        type: u4
      - id: wrap_s
        type: u4
      - id: wrap_t
        type: u4
      - id: min_filter
        type: u4
      - id: mag_filter
        type: u4
      - id: load_bias
        type: f4
      - id: edge_load
        type: u1
      - id: min_load
        type: u1
      - id: max_load
        type: u1
      - id: unpacked
        type: u1
    instances:
      data:
        pos: data_offset
        size-eos: true
        io: _root._io
  pal_header_t:
    seq:
      - id: num_entries
        type: u2
      - id: unknown1
        type: u2
      - id: palette_format
        type: u4
      - id: data_offset
        type: u4
