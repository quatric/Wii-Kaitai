meta:
  id: mact
  title: Petz MACT action table (Petz Sports)
  endian: be
doc: |
  File size is exactly 12 + name length + 28 N + 38 bytes. The meaning of the
  kinds, flags and hashes is not known.
seq:
  - id: magic
    contents: MACT
  - id: name_length
    type: u4
  - id: name
    size: name_length
    type: strz
    encoding: ASCII
  - id: n
    type: u4
  - id: id_hashes
    type: u4
    repeat: expr
    repeat-expr: n
  - id: links
    type: link
    repeat: expr
    repeat-expr: 3 * n + 1
  - id: gap1
    size: 16
  - id: records
    type: record
    repeat: expr
    repeat-expr: n
  - id: gap2
    size: 16
types:
  link:
    seq:
      - id: kind
        type: u1
      - id: flags
        type: u1
      - id: hash
        type: u4
  record:
    seq:
      - id: flags
        type: u2
      - id: a
        type: s2
      - id: b
        type: s2
    doc: -1 = none.
