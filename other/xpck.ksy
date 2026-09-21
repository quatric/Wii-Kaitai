meta:
  id: xpck
  endian: le
  title: Level-5 3DS/Switch container archive (XPCK/XPC2)
doc: |
  Level-5 container archive (.xc/.xpck), per lib-xpck.c. All table
  offsets/sizes are stored in units of 4 bytes.
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
    valid:
      any-of: ['"XPCK"', '"XPC2"']
  - id: packed_02
    type: u2
    doc: Low 12 bits are the file count; high 4 bits unknown.
  - id: file_info_offset_units
    type: u2
  - id: file_table_offset_units
    type: u2
  - id: data_offset_units
    type: u2
  - id: unknown_0c
    type: u2
  - id: filename_table_size_units
    type: u2
  - id: unknown_10
    size: 0x20 - 0x10
instances:
  num_files:
    value: packed_02 & 0xfff
  file_info_offset:
    value: file_info_offset_units * 4
  file_table_offset:
    value: file_table_offset_units * 4
  data_offset:
    value: data_offset_units * 4
  filename_table_size:
    value: filename_table_size_units * 4
  entries:
    type: entry_t
    repeat: expr
    repeat-expr: num_files
    pos: file_info_offset
types:
  entry_t:
    seq:
      - id: unknown_00
        size: 6
      - id: offset_lo
        type: u2
      - id: size_lo
        type: u2
      - id: offset_hi
        type: u1
      - id: size_hi
        type: u1
    instances:
      offset:
        value: (offset_lo | (offset_hi << 16)) * 4 + _root.data_offset
      size:
        value: size_lo | (size_hi << 16)
      body:
        pos: offset
        size: size
        io: _root._io
