meta:
  id: msgp
  title: Marvelous MSGP message package (.mpc)
  file-extension: mpc
  endian: be
doc: |
  Marvelous `MSGP` message package (Harvest Moon: Animal Parade `msglang/<lang>/
  <sex>/*.mpc`). Per entry an `MSGB` block (see `msgb`) holds the text as
  UTF-16BE (control codes like `%k%` / `%1c%` are part of the text).
seq:
  - id: magic
    contents: MSGP
  - id: version
    type: u4
    doc: 0x01000001.
  - id: count
    type: u4
  - id: table_offset
    type: u4
    doc: 0x14.
  - id: data_offset
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: id
        type: u4
      - id: offset
        type: u4
        doc: Relative to the data offset.
      - id: len_data
        type: u4
  msgb:
    seq:
      - id: magic
        contents: MSGB
      - id: version
        type: u4
        doc: 0x01000001.
      - id: a
        type: u4
      - id: b
        type: u4
      - id: c
        type: u4
      - id: d
        type: u4
      - id: text_offset
        type: u4
        doc: 0x20.
      - id: len_text
        type: u4
