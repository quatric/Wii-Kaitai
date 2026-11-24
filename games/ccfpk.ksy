meta:
  id: ccfpk
  title: CyberConnect2 fpack archive (.fpk)
  file-extension: fpk
  endian: be
doc: |
  Naruto Shippuden Clash of Ninja Revolution III, Tatsunoko vs. Capcom. Members
  with equal stored/unpacked sizes are raw; else Sega PRS read MSB first.
seq:
  - id: id
    type: u4
  - id: count
    type: u4
  - id: table_offset
    type: u4
    doc: 0x10.
  - id: file_size
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: name
        size: 0x24
        type: strz
        encoding: ASCII
      - id: offset
        type: u4
      - id: stored_size
        type: u4
      - id: unpacked_size
        type: u4
    instances:
      body:
        pos: offset
        size: stored_size
        io: _root._io
