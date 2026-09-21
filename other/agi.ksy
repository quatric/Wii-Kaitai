meta:
  id: agi
  file-extension: pak
  endian: be
  title: Toys for Bob AGI archive
doc: |
  A flat archive used by Toys for Bob titles (audio banks and mixed
  audio+model `.pak` files). A fixed 0x40-byte header gives the size of
  a variable-layout entry table and the location of a fixed-layout name
  table; the entry table's own record shape is not fixed by the format
  itself -- it is either a sequence of 2-word (offset, size) pairs (pure
  audio banks) or 4-word records (mixed audio+model banks, whose third
  word cannot be trusted as an on-disk size) and must be told apart
  heuristically, so it is kept here as an opaque byte blob; see
  lib-agi.c's `ScanAGI` for the full disambiguation logic.
seq:
  - id: magic
    contents: [0x1a, 0x41, 0x47, 0x49]
  - id: unknown0
    size: 4
  - id: len_entry_table
    type: u4
  - id: num_names
    type: u4
    doc: Number of members; also the number of entries in the name-offset table.
  - id: unknown1
    size: 0x1c
    doc: Bytes 0x10-0x2b of the header; purpose not established.
  - id: ofs_name_table
    type: u4
    doc: Absolute offset of the name table; verified to always land the table's end exactly at EOF.
  - id: len_name_table
    type: u4
  - id: unknown2
    size: 0x0c
    doc: Bytes 0x34-0x3f of the header, padding out to the fixed 0x40-byte header size.
  - id: entry_table
    size: len_entry_table
    doc: |
      Opaque 2-word or 4-word records; see the format doc above for why
      this can't be declared as a fixed Kaitai type.
instances:
  name_table:
    io: _root._io
    pos: ofs_name_table
    size: len_name_table
    type: name_table_t(num_names)
types:
  name_table_t:
    params:
      - id: count
        type: u4
    seq:
      - id: name_offsets
        type: u4
        repeat: expr
        repeat-expr: count
        doc: |
          Offsets (relative to the start of this table) of NUL-terminated
          backslash-path strings; each string is followed by 4 bytes of
          ignored hash/CRC. The string blob itself follows this offset
          array within the same byte range and is not modeled further
          here since its total length isn't independently recorded.
