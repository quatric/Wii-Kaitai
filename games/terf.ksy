meta:
  id: terf
  title: EA Tiburon TERF UI bundle
  file-extension: dat
  endian: be
doc: |
  Madden / NCAA / NASCAR Kart (Wii) `uis_*.dat`. DIR1 holds {offset, size}
  pairs relative to the DATA chunk; members are EA SHPG shape archives.
seq:
  - id: magic
    contents: TERF
  - id: header_size
    type: u4
    doc: 0x20 or 0x40.
  - id: unk
    size: header_size - 8
  - id: dir1
    type: dir1
  - id: data_tag
    contents: DATA
  - id: data_size
    type: u4
  - id: data
    size: data_size - 8
types:
  dir1:
    seq:
      - id: tag
        contents: DIR1
      - id: chunk_size
        type: u4
      - id: pairs
        type: pair
        repeat: expr
        repeat-expr: (chunk_size - 8) / 8
  pair:
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
