meta:
  id: marvelous_pbin
  title: Marvelous pBin container
  endian: be
doc: |
  Marvelous `pBin` container (Harvest Moon: Animal Parade, Wii; `.pBin`,
  `.cmp`, `.tak`, `.motma`, ...). At `table_offset` sit the 4-character type of
  the main body (DAT, FMS, ...) and `num_entries` 16-byte entries; the tag
  names the member (FMS model, TEX texture set, MOT motion, ...).
seq:
  - id: magic
    contents: pBin
  - id: one0
    type: u4
  - id: one1
    type: u4
  - id: minus_one
    type: u4
    doc: 0xFFFFFFFF.
  - id: table_offset
    type: u4
    doc: 0x20.
  - id: num_entries
    type: u4
  - id: len_main_body
    type: u4
  - id: main_body_offset
    type: u4
instances:
  main_type:
    pos: table_offset
    type: str
    size: 4
    encoding: ASCII
  entries:
    pos: table_offset + 4
    type: entry
    repeat: expr
    repeat-expr: num_entries
  main_body:
    pos: main_body_offset
    size: len_main_body
types:
  entry:
    seq:
      - id: zero
        type: u4
      - id: len_data
        type: u4
      - id: offset
        type: u4
      - id: tag
        type: str
        size: 4
        encoding: ASCII
    instances:
      data:
        pos: offset
        io: _root._io
        size: len_data
