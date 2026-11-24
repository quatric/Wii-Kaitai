meta:
  id: sonicone
  title: Sonic Team .one archive
  file-extension: one
  endian: be
doc: |
  Sonic and the Black Knight (Wii). Members are Sega PRS compressed.
seq:
  - id: count
    type: u4
  - id: table_offset
    type: u4
    doc: 0x10.
  - id: header_size
    type: u4
    doc: First data offset.
  - id: minus_one
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: name
        size: 0x20
        type: strz
        encoding: ASCII
      - id: index
        type: u4
      - id: offset
        type: u4
      - id: packed_size
        type: u4
      - id: unpacked_size
        type: u4
    instances:
      packed:
        pos: offset
        size: packed_size
        io: _root._io
