meta:
  id: ohasuta_wcdr
  title: Oha Suta WCDR0900 script container
  endian: be
doc: |
  Oha Suta Produce! Gentei Collabo Game Disc (Wii) script container. File size
  is `16 + 4 * count`. The meaning of the words (opcodes, arguments) is not
  known.
seq:
  - id: magic
    contents: WCDR0900
  - id: num_entries
    type: u4
  - id: header_word
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: id
        type: u2
      - id: value
        type: u2
