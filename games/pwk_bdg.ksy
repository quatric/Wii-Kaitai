meta:
  id: pwk_bdg
  title: Pipeworks bundle (.bdg)
  file-extension: bdg
  endian: be
doc: |
  Pipeworks bundle (Monster High: Ghoul Spirit, Wii): the text `Pipeworks bundle
  v1.30 (big endian)   \x1A\0` + bundle name, 0xEB padding up to 0x4C. Entry
  codec 0x24 = a zlib stream, 0x20 / 0x40 = stored. Entries that share an id come
  as a 16-byte stored head followed by the data. Names and types are in the
  sibling `.bdg.jnl` text journal and a trailing string table.
seq:
  - id: banner
    size: 0x4c
  - id: len_file
    type: u4
  - id: num_types
    type: u4
  - id: type_table_offset
    type: u4
  - id: len_type_table
    type: u4
  - id: num_entries
    type: u4
  - id: entry_table_offset
    type: u4
instances:
  entries:
    pos: entry_table_offset
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: offset
        type: u4
      - id: flags
        type: u1
      - id: len_data
        type: b24be
      - id: codec
        type: u1
      - id: len_stored
        type: b24be
      - id: id
        type: u4
        doc: Sorted ascending.
