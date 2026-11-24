meta:
  id: csvd
  title: CSVD spawn table
  file-extension: bin
  endian: be
doc: |
  `CSVD` spawn table (Link's Crossbow Training, Wii
  `res/ItemTable/enemy_table.bin`), followed by 0xFF padding. `#` names are
  empty slots.
seq:
  - id: magic
    contents: CSVD
  - id: count
    type: u4
  - id: records
    type: record
    repeat: expr
    repeat-expr: count
types:
  record:
    seq:
      - id: group_id
        type: u1
      - id: value
        type: u1
      - id: name
        size: 8
        type: strz
        encoding: ASCII
