meta:
  id: fcmpftex
  title: Muramasa The Demon Blade .ftx (FTEX block inside FCMP)
  file-extension: ftx
  endian: le
doc: |
  FCMP is an LZSS container around this block. Each texture is an "FTX0" chunk
  (u32 size, u32 data offset 0x40, zero padding) holding a standard TPL;
  chunks follow, 0x40-aligned, from the header size on.
seq:
  - id: magic
    contents: FTEX
  - id: total_size
    type: u4
  - id: header_size
    type: u4
    doc: 0x80.
  - id: count
    type: u4
  - id: pad
    size: 0x20 - 16
  - id: records
    type: record
    repeat: expr
    repeat-expr: count
types:
  record:
    seq:
      - id: name
        size: 0x20
        type: strz
        encoding: ASCII
      - id: zero
        type: u4
      - id: size
        type: u4
      - id: date
        size: 4
      - id: rest
        size: 0x30 - 0x20 - 12
