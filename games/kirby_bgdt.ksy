meta:
  id: kirby_bgdt
  title: BGDT stage background table (bg.dat)
  file-extension: dat
  endian: be
doc: |
  `BGDT` stage background table (Teolsil Kirby Iyagi / Kirby's Epic Yarn Korea,
  Wii `stage/stage*/bg.dat`). Each record is 13 words, ints and floats; file
  size is `20 + 52 * count`.
seq:
  - id: magic
    contents: BGDT
  - id: version
    type: u4
    doc: 1.
  - id: zero
    type: u4
  - id: capacity
    type: u4
    doc: 16.
  - id: num_records
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
        repeat-expr: 13
        doc: Ints or floats; field meanings are not documented.
