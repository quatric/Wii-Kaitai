meta:
  id: chf_pack
  title: Epic Mickey 2 pack (.chf)
  file-extension: chf
  endian: be
doc: |
  Disney Epic Mickey 2 `*.chf` pack (`animations.chf`). Data is 0x10 aligned,
  back to back; the last entry ends exactly at the end of the file.
seq:
  - id: magic
    contents: [0x85, 0x62, 0x02, 0x40]
  - id: count
    type: u4
  - id: zero
    size: 0x18
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: id
        type: u4
        doc: Id / hash.
      - id: offset
        type: u4
      - id: len_data
        type: u4
    instances:
      data:
        pos: offset
        io: _root._io
        size: len_data
