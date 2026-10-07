meta:
  id: wb_l10n
  title: So Blonde WB-L10n string table
  file-extension: dat
  endian: le
doc: |
  "WB-L10n" string table of So Blonde: Back to the Island (`Text/*.dat`).
  Little-endian; offsets are absolute and point at NUL-terminated UTF-8
  strings.
seq:
  - id: magic
    contents: ['WB-L10n', 0]
  - id: version
    type: u4
  - id: name
    type: strz
    size: 16
    encoding: ASCII
  - id: count
    type: u4
  - id: unknown
    type: u4
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: count
