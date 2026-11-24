meta:
  id: txag
  title: Sonic Team TXAG texture archive (.txd)
  file-extension: txd
  endian: be
doc: Sonic and the Black Knight. Each member is a complete GVR texture (GCIX/GBIX + GVRT).
seq:
  - id: magic
    contents: TXAG
  - id: count
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: name
        size: 0x20
        type: strz
        encoding: ASCII
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
