meta:
  id: pikmin_bx
  title: Pikmin 1 sound bank pikibank.bx
  file-extension: bx
  endian: be
doc: |
  Table of {offset, size} records followed by JAudio IBNK instrument banks and
  WSYS wave systems (offsets inside a WSYS are relative to it). Wave data is in
  the sibling .aw files (raw AFC). Table length is not stored; it ends at the
  first record's offset.
seq:
  - id: first
    type: record
  - id: rest
    type: record
    repeat: expr
    repeat-expr: first.offset / 8 - 1
types:
  record:
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
