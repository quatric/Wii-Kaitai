meta:
  id: gaftx
  title: Green Lantern Rise of the Manhunters .gaftx texture
  file-extension: gaftx
  endian: be
doc: Format 18 GX CMPR, 8 RGBA8, 9 / 11 16-bit GX formats.
seq:
  - id: width
    type: u2
  - id: height
    type: u2
  - id: width2
    type: u2
  - id: height2
    type: u2
  - id: marker
    type: u4
    doc: 0x10001.
  - id: format
    type: u4
  - id: base_level_size
    type: u4
  - id: zero
    type: u4
  - id: header_size
    type: u4
  - id: x10000
    type: u4
  - id: x38
    type: u4
  - id: data_offset
    type: u4
  - id: total_size_a
    type: u4
  - id: total_size_b
    type: u4
  - id: zero2
    size: 8
  - id: unk3c
    size: 0x38 - 0x30
  - id: mip_count
    type: u4
  - id: levels
    type: level
    repeat: expr
    repeat-expr: mip_count
types:
  level:
    seq:
      - id: width
        type: u2
      - id: height
        type: u2
      - id: end_offset
        type: u4
        doc: End of the level in the data.
      - id: zero
        type: u4
