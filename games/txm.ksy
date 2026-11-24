meta:
  id: txm
  title: Namco Tales of .txm texture directory
  file-extension: txm
  endian: be
doc: Pixel data lives in the matching .txv (GX tiled, mip chain after the top level).
seq:
  - id: magic
    type: u4
    doc: 0x20000.
  - id: size
    type: u4
  - id: ten
    type: u4
  - id: count
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: flags
        type: u4
      - id: width
        type: u4
      - id: height
        type: u4
      - id: mip_levels
        type: u4
      - id: format
        type: u4
        doc: 1 I8, 3 IA8, 6 RGBA8, 14 CMPR; flag bits above 16 ignored.
      - id: name_offset
        type: u4
        doc: Relative to this field.
      - id: data_offset
        type: u4
