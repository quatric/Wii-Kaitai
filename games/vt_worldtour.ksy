meta:
  id: vt_worldtour
  title: Virtua Tennis 2009 WorldTour.jam
  file-extension: jam
  endian: be
doc: Each section begins with 0x39d9c7d5 followed by a size-like word and zeros; fields are not interpreted.
seq:
  - id: magic
    type: u4
    doc: 0x3be0b3b1.
  - id: count
    type: u4
  - id: ids
    type: u4
    repeat: expr
    repeat-expr: count
  - id: body
    size-eos: true
