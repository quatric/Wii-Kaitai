meta:
  id: chans
  file-extension: cs
  endian: be
  title: Nintendo Wii ChannelScript
doc: |
  Compiled ECMAScript bytecode (`RCHE`) used by the Wii System Menu and
  WiiConnect24 channels -- Forecast Channel, News Channel, Photo Channel,
  Wii Shop Channel -- to run their dynamic banner scripts (`.cs`). All
  fields are big-endian.

  A fixed 32-byte header is followed by a sub-header whose fields are all
  section offsets/counts measured from the *end* of that 32-byte header
  (i.e. from file offset 0x20). The sections are: the bytecode itself
  ("FDS", First Data Section), a table of local methods, a table of
  imported symbols, a table of string literals, a table of exported
  symbols, and a table of per-256-byte "line start" bitmasks used by the
  debugger/disassembler to mark statement boundaries within the bytecode.

  Imported and exported symbol records are themselves a small indirection:
  each record gives a name's length and a byte offset (relative to the
  start of that record's own table) where the name characters live.
seq:
  - id: magic
    contents: "RCHE"
  - id: version
    type: u4
  - id: file_size
    type: u4
  - id: reserved
    size: 20
  - id: field_0
    type: u4
  - id: field_4
    type: u4
  - id: field_8
    type: u4
  - id: len_fds
    type: u4
    doc: Size in bytes of the bytecode (First Data Section).
  - id: ofs_fds
    type: u4
    doc: Offset of the bytecode, relative to 0x20.
  - id: num_exported
    type: u4
    doc: Count of exported symbols (table 4).
  - id: field_18
    type: u4
  - id: field_1c
    type: u4
  - id: num_methods
    type: u4
    doc: Count of local methods (table 1).
  - id: ofs_methods
    type: u4
    doc: Offset of the local-methods table, relative to 0x20.
  - id: num_imported
    type: u4
    doc: Count of imported symbols (table 2).
  - id: ofs_imported
    type: u4
    doc: Offset of the imported-symbols table, relative to 0x20.
  - id: num_strings
    type: u4
    doc: Count of string literals (table 3).
  - id: ofs_strings
    type: u4
    doc: Offset of the string-literal table, relative to 0x20.
  - id: field_38
    type: u4
  - id: field_3c
    type: u4
  - id: ofs_exported
    type: u4
    doc: Offset of the exported-symbols table, relative to 0x20.
  - id: ofs_line_blocks
    type: u4
    doc: Offset of the line-start bitmask table, relative to 0x20.
instances:
  base:
    value: 0x20
    doc: All section offsets above are relative to this file position.
  bytecode:
    pos: base + ofs_fds
    size: len_fds
    if: len_fds > 0
  methods:
    pos: base + ofs_methods
    type: method
    repeat: expr
    repeat-expr: num_methods
    if: num_methods > 0
  imported:
    pos: base + ofs_imported
    type: symbol_ref(base + ofs_imported)
    repeat: expr
    repeat-expr: num_imported
    if: num_imported > 0
  strings:
    pos: base + ofs_strings
    type: string_lit
    repeat: expr
    repeat-expr: num_strings
    if: num_strings > 0
  exported:
    pos: base + ofs_exported
    type: symbol_ref(base + ofs_exported)
    repeat: expr
    repeat-expr: num_exported
    if: num_exported > 0
  num_line_blocks:
    value: (len_fds + 255) / 256
    doc: One 0x24-byte block per 256 bytes of bytecode.
  line_blocks:
    pos: base + ofs_line_blocks
    type: line_block
    repeat: expr
    repeat-expr: num_line_blocks
    if: num_line_blocks > 0
types:
  method:
    doc: One local (non-exported-name) method within the bytecode.
    seq:
      - id: ofs_code
        type: u4
        doc: Offset of the method's first instruction, within the bytecode.
      - id: symbol_id
        type: u2
        doc: Index into the exported-symbols table (table 4) naming this method.
      - id: num_params
        type: u1
      - id: num_temps
        type: u1

  symbol_ref:
    doc: |
      An imported or exported symbol name. `ofs_name` is relative to the
      start of the table this record itself belongs to (passed in as
      `table_pos`), not to the record.
    params:
      - id: table_pos
        type: u4
    seq:
      - id: len_name
        type: u1
      - id: padding
        type: u1
      - id: ofs_name
        type: u2
    instances:
      name:
        io: _root._io
        pos: table_pos + ofs_name
        type: str
        size: len_name
        encoding: ASCII
        if: len_name > 0

  string_lit:
    doc: A UTF-16BE string literal, length-prefixed by its byte count.
    seq:
      - id: len_bytes
        type: u2
      - id: text
        type: str
        size: len_bytes
        encoding: UTF-16BE

  line_block:
    doc: |
      Marks, as a bitmask, which byte offsets within one 256-byte window
      of the bytecode begin a source line (used by the disassembler).
    seq:
      - id: ofs_block
        type: u4
      - id: bitmask
        size: 0x20
