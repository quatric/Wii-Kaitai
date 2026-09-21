meta:
  id: sfzdat
  endian: be
  title: Nintendo DAT/SFZDAT flat resource table
doc: |
  "DAT\0" flat resource table, per lib-sfzdat.c. Names use a
  fixed-stride array (a u32 stride followed by that many
  fixed-width, NUL-padded records); when that does not fit the file,
  the reference reader falls back to packed NUL-terminated strings.
  Only the common strided case is modeled here.
seq:
  - id: magic
    contents: [0x44, 0x41, 0x54, 0x00]
  - id: num_files
    type: u4
  - id: offsets_offset
    type: u4
  - id: extensions_offset
    type: u4
  - id: names_offset
    type: u4
  - id: sizes_offset
    type: u4
instances:
  file_offsets:
    type: u4
    repeat: expr
    repeat-expr: num_files
    pos: offsets_offset
    io: _io
  file_sizes:
    type: u4
    repeat: expr
    repeat-expr: num_files
    pos: sizes_offset
    io: _io
  name_stride:
    pos: names_offset
    type: u4
    io: _io
  names:
    pos: names_offset + 4
    type: str
    size: name_stride
    encoding: ASCII
    terminator: 0
    repeat: expr
    repeat-expr: num_files
    io: _io
