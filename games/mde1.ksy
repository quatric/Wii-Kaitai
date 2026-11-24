meta:
  id: mde1
  title: Little King's Story event table (MDE1)
  file-extension: bin
  endian: be
doc: |
  Ousama Monogatari / Little King's Story (Wii) event tables
  (`event/boot/MissionStartEventDB.bin`). 16-byte records of eight u16 values
  (0xFFFF = unused); the field meanings are not documented.
seq:
  - id: magic
    contents: MDE1
  - id: zero
    size: 12
  - id: records
    type: record
    repeat: eos
types:
  record:
    seq:
      - id: fields
        type: u2
        repeat: expr
        repeat-expr: 8
