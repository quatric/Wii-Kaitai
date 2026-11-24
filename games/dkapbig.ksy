meta:
  id: dkapbig
  title: Totally Spies Totally Party BIGFILE .TOC
  file-extension: toc
  endian: le
doc: |
  TOC for BIGFILEn.DAT (Ubisoft vdb_NGC). The first record is stored without
  its leading word; (count - 1) 36-byte records follow. Members follow back to
  back; a trailing 0xAAAAAAAA fill pads the TOC.
seq:
  - id: count
    type: u4
  - id: one
    type: u4
  - id: type_hash
    type: u4
  - id: size
    type: u4
  - id: pad
    size: 0x24 - 16
  - id: records
    type: record
    repeat: expr
    repeat-expr: count - 1
types:
  record:
    seq:
      - id: group
        type: u4
      - id: id
        type: u4
      - id: type_hash
        type: u4
      - id: size
        type: u4
      - id: offsets
        type: u4
        repeat: expr
        repeat-expr: 4
        doc: Four equal copies.
      - id: flag
        type: u4
