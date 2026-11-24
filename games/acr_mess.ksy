meta:
  id: acr_mess
  title: Another Code R text records (.MESS)
  file-extension: mess
  endian: be
doc: |
  Another Code R (Wii) `REVOLUTION/**/MESS/*.MESS` text records. Each record
  ends where the next record starts (the last one at the end of the file).
seq:
  - id: num_records
    type: u4
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: num_records
types:
  record:
    seq:
      - id: id
        type: u4
      - id: a
        type: u4
      - id: b
        type: u4
      - id: c
        type: u4
      - id: len_text
        type: u4
      - id: text
        type: str
        size: len_text
        encoding: UTF-8
        doc: Not NUL terminated.
