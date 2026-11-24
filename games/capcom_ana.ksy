meta:
  id: capcom_ana
  title: Capcom ANA@ archive (.ana)
  file-extension: ana
  endian: be
doc: Capcom `ANA@` archive; members are BRRES payloads named by an 8-byte name.
seq:
  - id: magic
    contents: ANA@
  - id: header_size
    type: u4
    doc: 0x20.
  - id: len_file
    type: u4
  - id: reserved0
    size: 0x14
  - id: count
    type: u4
  - id: reserved1
    size: 12
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: offset
        type: u4
      - id: len_data
        type: u4
      - id: name
        size: 8
        type: strz
        encoding: ASCII
    instances:
      data:
        pos: offset
        io: _root._io
        size: len_data
