meta:
  id: btxdlg
  title: K11 Kommissare im Einsatz dialog table (.btx)
  file-extension: btx
  endian: be
doc: Field kind 1 speaker, 2 spoken line, 3 emotion tag. The parse must consume the file exactly.
seq:
  - id: entry_count
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: entry_count
types:
  entry:
    seq:
      - id: id
        type: u4
      - id: field_count
        type: u4
      - id: fields
        type: field
        repeat: expr
        repeat-expr: field_count
  field:
    seq:
      - id: kind
        type: u4
      - id: unit_count
        type: u4
        doc: UTF-16 units including the terminating NUL.
      - id: text
        size: unit_count * 2
        type: str
        encoding: UTF-16BE
