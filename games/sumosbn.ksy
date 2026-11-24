meta:
  id: sumosbn
  title: Sumo Digital compiled script package
  file-extension: sbn
  endian: be
doc: Followed by tables, an embedded "smosbin" bytecode block and a string pool.
seq:
  - id: magic
    contents: smospkg2
  - id: header_size
    type: u4
    doc: 0x20.
  - id: count
    type: u4
  - id: guid
    size: 16
  - id: rest
    size-eos: true
