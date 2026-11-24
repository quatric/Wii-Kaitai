meta:
  id: tapsdat
  title: TAPS / Pet Vet style .dat package
  file-extension: dat
  endian: be
seq:
  - id: tag
    size: 0x20
    doc: Magic text such as "TAPSeaWii" or "Tier...".
  - id: count
    type: u4
  - id: ten_thousand
    type: u4
    doc: 0x10000.
  - id: pad
    size: 0x18
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: path
        size: 0x68
        type: strz
        encoding: ASCII
      - id: offset
        type: u4
      - id: stored_size
        type: u4
      - id: flag
        type: u4
        doc: 1 = zlib.
      - id: zero
        type: u4
      - id: unpacked_size
        type: u4
      - id: zero2
        type: u4
    instances:
      body:
        pos: offset
        size: stored_size
        io: _root._io
