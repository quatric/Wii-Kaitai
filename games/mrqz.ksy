meta:
  id: mrqz
  title: MRQZ archive (My Fitness Coach .pak)
  file-extension: pak
  endian: le
doc: |
  "MRQZ" archive from My Fitness Coach (Wii). Verified on all 565 retail
  paks. A fixed header, a table of 0x4c-byte entries at `header_size + 8` and
  raw members in a data block aligned to `header_size`.

  The data block starts at `align(header_size + 8 + 0x4c * count,
  header_size)`; entry offsets are relative to it and members are stored
  uncompressed.
seq:
  - id: magic
    contents: 'MRQZ'
  - id: end
    type: u4
    doc: File size minus 8.
  - id: version
    type: u2
    doc: Always 2.
  - id: header_size
    type: u2
    valid:
      any-of: [0x80, 0x1000]
  - id: count
    type: u4
  - id: header_rest
    size: header_size + 8 - 16
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
instances:
  data_start:
    value: >-
      ((header_size + 8 + 0x4c * count + header_size - 1) / header_size) * header_size
types:
  entry:
    seq:
      - id: name
        type: strz
        size: 64
        encoding: ASCII
      - id: offset
        type: u4
        doc: Relative to the data block (`data_start`).
      - id: size
        type: u4
      - id: reserved
        type: u4
        doc: Always 0.
    instances:
      body:
        pos: _root.data_start + offset
        size: size
        io: _root._io
