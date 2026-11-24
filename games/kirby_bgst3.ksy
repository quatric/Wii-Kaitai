meta:
  id: kirby_bgst3
  title: Good-Feel BGST background tile set (.bgst3)
  file-extension: bgst3
  endian: be
doc: |
  Good-Feel `BGST` background tile set (Kirby's Epic Yarn). The tile data is a
  plain run of `tile_count` GX CMPR tiles of `width * height / 2` bytes each,
  which ends the file. The slot table at 0x40 holds 16-byte records (0xFFFF /
  0xFFFE = none); it runs up to `tile_data_start`.
seq:
  - id: magic
    contents: BGST
  - id: version
    type: u4
    doc: 0x10 or 0x11.
  - id: tile_width
    type: u4
    doc: 512.
  - id: tile_height
    type: u4
    doc: 512.
  - id: kind
    type: u4
  - id: three
    type: u4
  - id: tile_count
    type: u4
  - id: reserved
    size: 12
  - id: table_offset
    type: u4
    doc: 0x40.
  - id: tile_data_start
    type: u4
instances:
  slots:
    pos: table_offset
    type: slot
    repeat: expr
    repeat-expr: (tile_data_start - table_offset) / 16
  tiles:
    pos: tile_data_start
    size: tile_width * tile_height / 2
    repeat: expr
    repeat-expr: tile_count
types:
  slot:
    seq:
      - id: used
        type: u2
      - id: layer
        type: u2
      - id: x
        type: u2
      - id: y
        type: u2
      - id: tile_ids
        type: u2
        repeat: expr
        repeat-expr: 4
