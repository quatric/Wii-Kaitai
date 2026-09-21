meta:
  id: ztab
  endian: be
  title: Camelot Archive Table (.ztab)
doc: |
  Camelot Archive Table, per lib-ztab.c.
seq:
  - id: magic
    contents: "ZTAB"
  - id: num_entries
    type: u4
  - id: entries
    type: entry_t
    repeat: expr
    repeat-expr: num_entries
types:
  entry_t:
    seq:
      - id: flags
        type: u4
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: unknown_0c
        type: u4
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
