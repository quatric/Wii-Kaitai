meta:
  id: tdbtext
  title: Super Monkey Ball TXDB text table
  file-extension: tdb
  endian: be
seq:
  - id: magic
    contents: TXDB
  - id: version
    type: u4
    doc: 3.
  - id: zero
    type: u4
  - id: end
    type: u4
  - id: index_offset
    type: u4
  - id: unk
    type: u4
  - id: pool_offset
    type: u4
  - id: pool_size
    type: u4
instances:
  index:
    pos: index_offset
    type: ref
    repeat: expr
    repeat-expr: (pool_offset - index_offset) / 4
  pool:
    pos: pool_offset
    size: pool_size
types:
  ref:
    seq:
      - id: offset
        type: u2
      - id: length
        type: u2
