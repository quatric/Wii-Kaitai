meta:
  id: pms_pac
  title: Dog Island container (.pac, .tex)
  file-extension: pac
  endian: be
doc: |
  Dog Island (Artlist Collection, Wii) `pms/*.pac`, `pms/*.tex` and extensionless
  `chara/<n>` containers; payloads sit at the stored offsets.
seq:
  - id: count
    type: u4
  - id: constant_0x10000
    type: u4
  - id: zero
    type: u4
  - id: header_size
    type: u4
    doc: 0x10.
  - id: records
    type: record
    repeat: expr
    repeat-expr: count
types:
  record:
    seq:
      - id: name
        size: 16
        type: strz
        encoding: ASCII
      - id: type
        size: 4
        type: strz
        encoding: ASCII
      - id: len_data
        type: u4
      - id: offset
        type: u4
      - id: zero
        type: u4
