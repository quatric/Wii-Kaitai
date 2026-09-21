meta:
  id: stpk
  endian: be
  title: Jump Super Stars / Jump Ultimate Stars DS archive (STPK)
doc: |
  Jump Super Stars / Jump Ultimate Stars DS archive (.srd/.stpk),
  per lib-stpk.c.
seq:
  - id: magic
    contents: "STPK"
  - id: unknown_04
    size: 4
  - id: num_resources
    type: u4
  - id: unknown_0c
    size: 4
  - id: entries
    type: entry_t
    repeat: expr
    repeat-expr: num_resources
types:
  entry_t:
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: unknown_08
        size: 8
      - id: name
        type: str
        size: 0x30 - 0x10
        encoding: ASCII
        terminator: 0
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
