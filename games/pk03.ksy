meta:
  id: pk03
  title: Hash-indexed PK03 package (Deer Drive Legends)
  file-extension: pak
  endian: be
doc: |
  Hash-indexed `PK03` package (Deer Drive Legends `Game.pak` /
  `GameStatic.pak`); records sorted by hash (algorithm unknown). Flag 1 = the
  member is an LZ11 stream, 0 = stored.
seq:
  - id: magic
    contents: PK03
  - id: zero
    type: u4
  - id: count
    type: u4
  - id: records
    type: record
    repeat: expr
    repeat-expr: count
types:
  record:
    seq:
      - id: name_hash
        type: u4
      - id: offset
        type: u4
      - id: size_shl_8_or_flags
        type: u4
        doc: '`size << 8 | flags`.'
