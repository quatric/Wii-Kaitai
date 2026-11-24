meta:
  id: gos1
  title: Sega gos1 object-set pack (.gos)
  file-extension: gos
  endian: be
doc: |
  Sega `gos1` object-set pack (Ghost Squad `*.gos`). The offset table ends
  exactly where the first member starts; members run back to back and the last
  ends at the end of the file. Every member starts with its NUL-terminated name.
seq:
  - id: unknown
    type: u4
  - id: magic
    contents: gos1
  - id: count
    type: u2
  - id: zero
    type: u2
  - id: member_offsets
    type: u4
    repeat: expr
    repeat-expr: count
