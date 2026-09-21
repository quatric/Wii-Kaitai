meta:
  id: chans
  file-extension: cs
  endian: be
  title: Nintendo Wii ChannelScript compiled bytecode (RCHE)
doc: |
  Compiled ECMAScript bytecode format used by the Wii System Menu and
  WiiConnect24 channels (Forecast Channel, News Channel, Photo Channel,
  Wii Shop Channel) to run dynamic banner scripts (`.cs`).

  All section offsets in the sub-header are relative to the end of the
  32-byte main header (i.e. absolute offset = 0x20 + field value).
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
    valid: '"RCHE"'
  - id: version
    type: u4
  - id: file_size
    type: u4
  - id: reserved
    size: 20
  - id: sub_header
    type: sub_header
instances:
  bytecode:
    io: _io
    pos: 0x20 + sub_header.ofs_fds
    size: sub_header.len_fds
    if: sub_header.len_fds > 0
  local_methods:
    io: _io
    pos: 0x20 + sub_header.ofs_table1
    type: method
    repeat: expr
    repeat-expr: sub_header.count_table1
  imported_symbols:
    io: _io
    pos: 0x20 + sub_header.ofs_table2
    type: symbol
    repeat: expr
    repeat-expr: sub_header.count_table2
  exported_symbols:
    io: _io
    pos: 0x20 + sub_header.ofs_table4
    type: symbol
    repeat: expr
    repeat-expr: sub_header.count_table4
types:
  sub_header:
    seq:
      - id: field_0
        type: u4
      - id: field_4
        type: u4
      - id: field_8
        type: u4
      - id: len_fds
        type: u4
        doc: Bytecode (First Data Section) size.
      - id: ofs_fds
        type: u4
        doc: Bytecode offset, relative to 0x20.
      - id: count_table4
        type: u4
        doc: Exported symbols count.
      - id: field_18
        type: u4
      - id: field_1c
        type: u4
      - id: count_table1
        type: u4
        doc: Local methods count.
      - id: ofs_table1
        type: u4
        doc: Local methods offset, relative to 0x20.
      - id: count_table2
        type: u4
        doc: Imported symbols count.
      - id: ofs_table2
        type: u4
        doc: Imported symbols offset, relative to 0x20.
      - id: count_table3
        type: u4
        doc: String literals count.
      - id: ofs_table3
        type: u4
        doc: String literals offset, relative to 0x20.
      - id: field_38
        type: u4
      - id: field_3c
        type: u4
      - id: ofs_table4
        type: u4
        doc: Exported symbols offset, relative to 0x20.
      - id: ofs_table5
        type: u4
        doc: Line-start bitmasks offset, relative to 0x20.
  method:
    doc: Table 1 entry - a local method.
    seq:
      - id: ofs_bytecode
        type: u4
        doc: Offset of this method's code in the FDS bytecode.
      - id: symbol_id
        type: u2
        doc: Index into the exported symbols table (Table 4).
      - id: param_count
        type: u1
      - id: temp_count
        type: u1
  symbol:
    doc: Table 2 (imported) / Table 4 (exported) entry.
    seq:
      - id: length
        type: u1
      - id: padding
        type: u1
      - id: ofs_name
        type: u2
        doc: Offset of this symbol's name, relative to the table start.
