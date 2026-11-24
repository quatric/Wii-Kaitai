meta:
  id: tpx
  title: Atlus TPX texture pack (Trauma Team)
  file-extension: tpx
  endian: be
doc: Each record points at a standard TPL.
seq:
  - id: build_date
    type: u4
    doc: 0x2006xxxx.
  - id: small_field
    type: u4
  - id: header_size
    type: u4
    doc: 0x20 + 0x20 * count.
  - id: count
    type: u4
  - id: pad
    size: 0x10
  - id: records
    type: record
    repeat: expr
    repeat-expr: count
types:
  record:
    seq:
      - id: flags
        type: u4
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: name
        size: 0x14
        type: strz
        encoding: ASCII
    instances:
      tpl:
        pos: offset
        size: size
        io: _root._io
