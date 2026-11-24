meta:
  id: sega_glip
  title: SEGA GLIP lip-sync table (.cnk)
  file-extension: cnk
  endian: le
doc: |
  SEGA `GLIP` lip-sync table (Sakura Wars: So Long, My Love `*.cnk`). Keys are
  sorted (0x16000 + n for the first ones, voice ids such as 0x1F7EE later); offsets
  are relative to 0x10 (the count field); a record runs to the next offset. A
  record byte is `{mouth pattern: 3 bits, frames: 5 bits}`, the pattern held for
  that many frames; pattern 6 ends the record (the pattern goes to the face as
  mouth 0..5, 6 -> -1).
seq:
  - id: magic
    contents: GLIP
  - id: len_file
    type: u4
  - id: header_size
    type: u4
    doc: 0x10.
  - id: zero
    type: u4
  - id: count
    type: u4
  - id: eight
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: key
        type: u4
      - id: record_offset
        type: u4
