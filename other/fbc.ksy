meta:
  id: fbc
  file-extension: fbc
  endian: be
  title: h.a.n.d. FBC file bundle
doc: |
  File bundle format used by *Oyako de Asobo: Miffy no Omochabako* (Wii).
  Big-endian throughout. A fixed 0x40-byte header (only the file count at
  0x04 is understood; the other five reserved u32s at 0x10 are unused by
  the reader), followed by a table of `num_files` member offsets (relative
  to 0x40, so member 0 begins right after this offset table plus the size
  and name tables described below).

  The last `2 * num_files` 32-byte slots of the file are a size table
  (u32 size + zero-padding to 32 bytes) immediately followed by a name
  table (NUL-terminated ASCII name, zero-padded to 32 bytes). Members
  themselves sit back to back between the offset table and the size
  table; a nested bundle re-uses the same layout starting right at its own
  member offset.
seq:
  - id: reserved0
    type: u2
    doc: Always 0.
  - id: format_tag
    contents: [0, 0x14]
  - id: kind_tag
    contents: [0, 6]
  - id: num_files
    type: u4
  - id: reserved
    size: 24
    doc: Six reserved u32 slots (table offsets in other FBC users; unused here).
  - id: member_offsets
    type: u4
    repeat: expr
    repeat-expr: num_files
    doc: Offset of each member, relative to 0x40 (the end of this header).
instances:
  sizes_ofs:
    value: _io.size - 64 * num_files.as<u4> - 32 * num_files.as<u4>
  names_ofs:
    value: sizes_ofs + 32 * num_files.as<u4>
  sizes:
    pos: sizes_ofs
    type: size_entry
    repeat: expr
    repeat-expr: num_files
  names:
    pos: names_ofs
    type: name_entry
    repeat: expr
    repeat-expr: num_files
types:
  size_entry:
    seq:
      - id: size
        type: u4
      - id: padding
        size: 28
  name_entry:
    seq:
      - id: name
        type: strz
        encoding: ASCII
        size: 32
