meta:
  id: xar
  title: xar archive (Toushinden)
  file-extension: xar
  endian: be
doc: Members starting with "BZh" are bzip2-compressed.
seq:
  - id: magic
    contents: ["xar", 0x20]
  - id: count
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: name_offset
        type: u4
      - id: name_length
        type: u4
      - id: data_offset
        type: u4
      - id: data_size
        type: u4
    instances:
      name:
        pos: name_offset
        size: name_length
        type: str
        encoding: ASCII
        io: _root._io
      data:
        pos: data_offset
        size: data_size
        io: _root._io
