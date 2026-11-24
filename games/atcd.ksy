meta:
  id: atcd
  title: ATCD text catalog (Safar'Wii)
  file-extension: dat
  endian: be
doc: |
  `ATCD` text catalog (Safar'Wii, Wii `2d/<lang>/text/text_*.dat`). Each
  entry is a 0x20-byte ASCII key followed by u32 words; words pointing behind
  the entry table to a NUL-terminated UTF-16BE string (even offsets, shared
  strings allowed) are strings, the others numbers.
seq:
  - id: magic
    contents: ATCD
  - id: zero
    type: u4
  - id: column_hint
    type: u4
  - id: entry_stride
    type: u4
  - id: num_entries
    type: u4
  - id: entries_offset
    type: u4
    doc: 0x20.
  - id: unknown0
    type: u4
  - id: unknown1
    type: u4
instances:
  entries:
    pos: entries_offset
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: key
        size: 0x20
        type: strz
        encoding: ASCII
      - id: words
        type: u4
        repeat: expr
        repeat-expr: (_root.entry_stride - 0x20) / 4
