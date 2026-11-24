meta:
  id: ssrt
  title: SSRT parameter database (Sonic & Sega All-Stars Racing)
  file-extension: dat
  endian: be
doc: |
  Type hashes: 0xa45c088e float, 0xfbe46712 int, 0xb7459825 string (value =
  absolute file offset), 0x1e2a64fb hash/id. A NUL-separated string table and
  the end marker 0xdeadbeef follow the last item. Field names are hashes only.
seq:
  - id: magic
    contents: SSRT
  - id: version
    type: u4
  - id: table_offset
    type: u4
    doc: 0x10..0x80.
instances:
  table:
    pos: table_offset
    type: table
types:
  table:
    seq:
      - id: table_hash
        type: u4
      - id: name
        size: 0x40
        type: strz
        encoding: ASCII
      - id: item_count
        type: u4
      - id: item_offsets
        type: u4
        repeat: expr
        repeat-expr: item_count
  item:
    seq:
      - id: field_count
        type: u4
      - id: item_hash
        type: u4
      - id: name
        size: 0x40
        type: strz
        encoding: ASCII
      - id: fields
        type: field
        repeat: expr
        repeat-expr: field_count
  field:
    seq:
      - id: name_hash
        type: u4
      - id: type_hash
        type: u4
      - id: value
        type: u4
