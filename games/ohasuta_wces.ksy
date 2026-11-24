meta:
  id: ohasuta_wces
  title: Oha Suta WCES0901 event container
  endian: be
doc: |
  Oha Suta Produce! Gentei Collabo Game Disc (Wii) event container. File size
  is `16 + 32 * count`. The meaning of the words is not known.
seq:
  - id: magic
    contents: WCES0901
  - id: num_records
    type: u4
  - id: zero
    type: u4
  - id: records
    type: record
    repeat: expr
    repeat-expr: num_records
types:
  record:
    seq:
      - id: words
        type: u4
        repeat: expr
        repeat-expr: 8
