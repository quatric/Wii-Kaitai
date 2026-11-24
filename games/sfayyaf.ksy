meta:
  id: sfayyaf
  title: Yuke's SFAY sound bank (.yaf)
  file-extension: yaf
  endian: le
doc: |
  WWE SmackDown vs. Raw (Wii) `sound/*.yaf`. Little-endian; every member is a
  mono Nintendo DSP-ADPCM file.
seq:
  - id: magic
    contents: SFAY
  - id: header_size_be
    type: u4be
    doc: 0x10 stored big-endian.
  - id: name
    size: 16
    type: strz
    encoding: ASCII
  - id: zero
    type: u4
  - id: count
    type: u4
  - id: alignment
    type: u4
  - id: one
    type: u4
  - id: entry_size
    type: u4
    doc: 12.
  - id: table_offset
    type: u4
    doc: 0x2c.
instances:
  entries:
    pos: table_offset
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: size
        type: u4
      - id: offset
        type: u4
      - id: id
        type: u4
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
