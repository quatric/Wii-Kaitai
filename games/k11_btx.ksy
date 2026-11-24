meta:
  id: k11_btx
  title: K11 dialog table (.btx)
  file-extension: btx
  endian: be
doc: |
  K11 - Kommissare im Einsatz (Germany, Wii) dialog tables
  `wii/Text/<LANG>/*.btx`. Field kind 1 is the speaker, 2 the spoken line, 3 an
  extra text.
seq:
  - id: num_entries
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: id
        type: u4
      - id: num_fields
        type: u4
      - id: fields
        type: field
        repeat: expr
        repeat-expr: num_fields
  field:
    seq:
      - id: kind
        type: u4
      - id: num_units
        type: u4
        doc: UTF-16 units including the terminating NUL.
      - id: text
        type: str
        size: num_units * 2
        encoding: UTF-16BE
