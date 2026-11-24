meta:
  id: ccd
  title: Tom Clancy's HAWX 2 object container (.ccd)
  file-extension: ccd
  endian: be
doc: |
  Tom Clancy's H.A.W.X. 2 `*.ccd` object container. `n` ascending record
  offsets from +0x1C (the first record starts right after the table); each
  record begins with a pointer to its NUL-terminated name in the string pool
  behind the last record. A record ends where the next starts, the last one at
  the lowest name pointer.
seq:
  - id: len_file
    type: u4
  - id: num_records
    type: u4
  - id: table_offset
    type: u4
    doc: 0x1c.
  - id: reserved
    size: 16
  - id: record_offsets
    type: u4
    repeat: expr
    repeat-expr: num_records
