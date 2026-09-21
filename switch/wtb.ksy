meta:
  id: wtb
  endian: le
  title: Nintendo Switch Texture Archive (WTB)
doc: |
  Nintendo Switch Texture Archive (.wta header + .wtp image data),
  per lib-wtb.c (ported from KillzXGaming/Switch-Toolbox WTB.cs).
  Tegra block-linear pixel data is not detiled here; pixels live
  either in this same buffer or a sibling .wtp file.
seq:
  - id: magic
    contents: [0x57, 0x54, 0x42]
  - id: unknown_03
    type: u1
  - id: num_textures
    type: u4
  - id: data_offset_table
    type: u4
  - id: data_size_table
    type: u4
  - id: unknown_14
    size: 0x1c - 0x14
  - id: texture_info_table
    type: u4
instances:
  data_offsets:
    type: u4
    repeat: expr
    repeat-expr: num_textures
    pos: data_offset_table
  data_sizes:
    type: u4
    repeat: expr
    repeat-expr: num_textures
    pos: data_size_table
  texture_infos:
    type: texture_info_t
    repeat: expr
    repeat-expr: num_textures
    pos: texture_info_table
types:
  texture_info_t:
    doc: 56-byte record.
    seq:
      - id: magic
        contents: "XT1 "
      - id: unknown_04
        size: 16
      - id: mip_count
        type: u4
      - id: surface_type
        type: u4
      - id: format
        type: u4
      - id: width
        type: u4
      - id: height
        type: u4
      - id: depth
        type: u4
      - id: unknown_2c
        size: 4
      - id: texture_layout
        type: u4
