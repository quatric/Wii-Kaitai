meta:
  id: lmxbdb
  title: Deadly Creatures .wii.database LMXB block
  endian: be
doc: |
  Header {"LMXB", 0x03ec0001, 5 counts, id, 0, zlib size} + zlib payload,
  sometimes followed by size-prefixed Lua 5.1 bytecode. Embedded little-endian
  FMOD FSB4 banks sit after the tables.
seq:
  - id: magic
    contents: LMXB
  - id: version
    type: u4
    doc: 0x03ec0001.
  - id: counts
    type: u4
    repeat: expr
    repeat-expr: 5
  - id: id
    type: u4
  - id: zero
    type: u4
  - id: zlib_size
    type: u4
  - id: payload
    size: zlib_size
    process: zlib
  - id: rest
    size-eos: true
