meta:
  id: uranai_score_table_jp
  title: Today & Tomorrow Channel - fortune score table (Japanese build)
  application: Today & Tomorrow Channel
  endian: be
doc: |
  The Japanese build compiles the original fortune text into the program, so its table
  entries are 20 bytes and carry static pointers to up to four Shift-JIS lines of the
  message (about 14 full-width characters each) instead of the runtime-filled six line
  pointers of the other builds. Six tables of 360 entries, 0x1C20 bytes apart, starting at
  0x8036C448; slice `6 * 0x1C20` bytes.

  The `score` column is byte-for-byte the same as the EU and Korean tables (all 2,160
  values), so the scoring engine is identical; only the text storage differs. The lines
  point into the string pool at 0x8033F790 onward. A pointer to an empty string (in
  `.sdata`, 0x80557B10) marks an unused line.
seq:
  - id: topics
    type: topic
    repeat: expr
    repeat-expr: 6
types:
  topic:
    seq:
      - id: entries
        type: entry
        repeat: expr
        repeat-expr: 360
  entry:
    seq:
      - id: sign
        type: u1
      - id: degree
        type: u1
      - id: score
        type: u1
      - id: zero
        type: u1
      - id: line_pointers
        type: u4
        repeat: expr
        repeat-expr: 4
        doc: virtual addresses of NUL-terminated Shift-JIS lines
