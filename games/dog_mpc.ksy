meta:
  id: dog_mpc
  title: Dog Island static.mpc
  file-extension: mpc
  endian: be
doc: |
  Dog Island (Artlist Collection, Wii) `static.mpc` table pack. The first
  records are directory headers (tag high byte 0), the leaf records (tag
  `0xff<count>`, count = number of fixed-size rows in the block) give each data
  block's offset relative to the data start; a block ends where the next begins.
  Row contents are not decoded.
seq:
  - id: len_table
    type: u4
  - id: len_data
    type: u4
  - id: constant_0x20
    type: u4
  - id: data_start
    type: u4
    doc: 0x20 + table bytes.
  - id: one
    type: u4
  - id: zeros
    size: 12
  - id: records
    type: record
    repeat: expr
    repeat-expr: len_table / 0x28
types:
  record:
    seq:
      - id: tag
        type: u4
      - id: name
        size: 0x20
        type: strz
        encoding: ASCII
      - id: offset
        type: u4
