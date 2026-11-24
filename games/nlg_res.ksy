meta:
  id: nlg_res
  title: Next Level Games resource file (.res, .dmn)
  endian: be
doc: |
  Next Level Games `.res` / `.dmn` resource file (Mario Strikers Charged, Wii).
  Texture banks use the same texture header as `nlg_rlt`; entries that are not
  textures exist too.
seq:
  - id: constant_0x20
    type: u4
  - id: count
    type: u4
  - id: reserved
    size: 0x18
  - id: records
    type: record
    repeat: expr
    repeat-expr: count
types:
  record:
    seq:
      - id: name_hash
        type: u4
      - id: offset_div_0x20
        type: u4
      - id: len_data
        type: u4
