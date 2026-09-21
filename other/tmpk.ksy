meta:
  id: tmpk
  endian: be
  title: Twilight Princess HD / Zelda TMPK archive (.pack)
doc: |
  Twilight Princess HD / Zelda TMPK archive, per lib-tmpk.c.
seq:
  - id: magic
    contents: "TMPK"
  - id: num_files
    type: u4
  - id: alignment
    type: u4
  - id: unknown_0c
    size: 4
  - id: entries
    type: entry_t
    repeat: expr
    repeat-expr: num_files
types:
  entry_t:
    seq:
      - id: name_offset
        type: u4
      - id: file_offset
        type: u4
      - id: file_size
        type: u4
      - id: unknown_0c
        type: u4
    instances:
      name:
        pos: name_offset
        type: str
        terminator: 0
        encoding: ASCII
        io: _root._io
      body:
        pos: file_offset
        size: file_size
        io: _root._io
