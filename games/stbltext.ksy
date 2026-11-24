meta:
  id: stbltext
  title: Harvest Moon Animal Parade STBL string table
  file-extension: stb
  endian: be
seq:
  - id: magic
    contents: STBL
  - id: version
    type: u4
    doc: 0x01000001.
  - id: entry_count
    type: u4
  - id: string_width
    type: u4
    doc: Bytes per string, 0x40.
  - id: table_offset
    type: u4
    doc: 0x18.
  - id: data_offset
    type: u4
instances:
  entries:
    pos: table_offset
    type: entry
    repeat: expr
    repeat-expr: entry_count
types:
  entry:
    seq:
      - id: id
        type: u4
      - id: zero
        type: u4
      - id: string_count
        type: u4
      - id: first_string_offset
        type: u4
    instances:
      strings:
        pos: first_string_offset
        io: _root._io
        type: str_fixed
        repeat: expr
        repeat-expr: string_count
  str_fixed:
    seq:
      - id: text
        size: _root.string_width
        type: str
        encoding: UTF-16BE
