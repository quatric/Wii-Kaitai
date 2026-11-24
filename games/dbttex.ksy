meta:
  id: dbttex
  title: Dragon Ball Z Budokai Tenkaichi 2 .dbt texture bundle
  file-extension: dbt
  endian: be
doc: Three GX descriptors at 0x100 (stride 0x24), each 512x512 CMPR image back to back from 0x180.
seq:
  - id: three
    type: u4
  - id: eight
    type: u4
  - id: pad
    size: 0x100 - 8
  - id: descriptors
    type: descriptor
    repeat: expr
    repeat-expr: 3
types:
  descriptor:
    seq:
      - id: zero
        type: u4
      - id: width
        type: u2
      - id: height
        type: u2
      - id: gx_format
        type: u4
      - id: rest
        size: 0x24 - 12
