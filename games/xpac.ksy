meta:
  id: xpac
  title: Hasbro Family Game Night 3 .xpac
  file-extension: xpac
  endian: be
doc: Payloads are 0x800-aligned; XML scenes or runs of DSP-ADPCM files.
seq:
  - id: zero0
    type: u4
  - id: zero1
    type: u4
  - id: alignment
    type: u4
    doc: 0x800.
  - id: count
    type: u4
  - id: pad
    size: 8
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: name_hash
        type: u4
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: size2
        type: u4
      - id: zero
        type: u4
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
