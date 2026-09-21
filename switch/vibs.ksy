meta:
  id: vibs
  endian: le
  title: Nintendo Switch Joy-Con Vibration Archive (.vibs)
doc: |
  Nintendo Switch Joy-Con vibration archive, per lib-vibs.c.
seq:
  - id: version
    type: u4
  - id: num_entries
    type: u4
  - id: entries
    type: entry_t
    repeat: expr
    repeat-expr: num_entries
types:
  entry_t:
    seq:
      - id: name
        type: str
        size: 24
        encoding: ASCII
        terminator: 0
      - id: unknown_18
        size: 32 - 24
      - id: data_length
        type: u4
      - id: unknown_24
        size: 40 - 36
      - id: data_offset
        type: u4
    instances:
      body:
        pos: data_offset
        size: data_length
        io: _root._io
