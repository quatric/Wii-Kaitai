meta:
  id: pipeworks_bdg
  title: Pipeworks "bundle v1.03 (big endian)" archive (.bdg)
  file-extension: bdg
  endian: be
doc: |
  Pipeworks Software bundle (Merv Griffin's Crosswords, ...). A 0x26-byte text
  banner (`Pipeworks bundle v1.03 (big endian)`), then big-endian header fields
  at 0x30. Names are stored only as hashes, so nintoolbox writes members as
  `<hash>_<type>.bin` (`.txt` when plain text). Entries whose data lies outside
  the file (stored in a sibling bundle) are skipped; zlib members (type name
  `Ifc`) are inflated.
seq:
  - id: banner
    size: 0x26
  - id: pad_26
    size: 6
  - id: unknown_2c
    type: u4
  - id: num_types
    type: u4
  - id: type_table_offset
    type: u4
  - id: type_table_size
    type: u4
    doc: Type names, NUL-terminated.
  - id: num_entries
    type: u4
  - id: entry_offset
    type: u4
instances:
  type_table:
    pos: type_table_offset
    size: type_table_size
  entries:
    pos: entry_offset
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: file_offset
        type: u4
      - id: type_and_size
        type: u4
        doc: '`type << 24 | size`.'
      - id: name_hash
        type: u4
    instances:
      type_index:
        value: type_and_size >> 24
      size:
        value: type_and_size & 0xffffff
