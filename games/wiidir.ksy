meta:
  id: wiidir
  title: Agatha Christie And Then There Were None .wii bundle
  file-extension: wii
  endian: le
seq:
  - id: count
    type: u4
  - id: zero
    size: 0x1c
  - id: records
    type: record
    repeat: expr
    repeat-expr: count
types:
  record:
    seq:
      - id: path
        size: 0xf4
        doc: Backslash separated, 0xcd padded.
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: size_used
        type: u4
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
