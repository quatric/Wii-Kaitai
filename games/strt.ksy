meta:
  id: strt
  title: One Piece "STRT" string table
  file-extension: bin
  endian: be
doc: |
  "STRT" string table of One Piece Unlimited Adventure / Cruise (`.bin`,
  `.str`). The count is not stored: `count = (offsets[0] - 12) / 4`, since the
  first string follows the offset table directly. Offsets are absolute and
  point at NUL-terminated strings.
seq:
  - id: magic
    contents: 'STRT'
  - id: unknown
    type: u4
  - id: lang
    type: str
    size: 4
    encoding: ASCII
    doc: Language tag NUL-padded (`en`).
  - id: first_offset
    type: u4
  - id: more_offsets
    type: u4
    repeat: expr
    repeat-expr: count - 1
instances:
  count:
    value: (first_offset - 12) / 4
