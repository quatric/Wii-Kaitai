meta:
  id: mrv_pbin_dpt
  title: Marvelous pBin resource pack (.dpt)
  file-extension: dpt
  endian: be
doc: |
  Marvelous `pBin` resource packs (Harvest Moon: Animal Parade `*.dpt` and
  siblings). Entries are `{char tag[4] ("FMS ", "TEX ", "UVM ", ...), u32 0, u32
  size, u32 offset}`, unlike the tag-last entries of `marvelous_pbin`.
seq:
  - id: magic
    contents: pBin
  - id: one0
    type: u4
  - id: one1
    type: u4
  - id: minus_one
    type: u4
  - id: table_offset
    type: u4
    doc: 0x20.
  - id: count
    type: u4
instances:
  entries:
    pos: table_offset
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: tag
        type: str
        size: 4
        encoding: ASCII
      - id: zero
        type: u4
      - id: len_data
        type: u4
      - id: offset
        type: u4
