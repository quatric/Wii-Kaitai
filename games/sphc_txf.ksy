meta:
  id: sphc_txf
  title: SPHC / Storm City Games locale string table (.txf)
  file-extension: txf
  endian: le
doc: |
  Locale string table of Storm City Games' engine (Gummy Bears MiniGolf, Pool
  Hall Pro, Vertigo, ...): a count, `count` absolute offsets and
  NUL-terminated UTF-8 strings.
seq:
  - id: count
    type: u4
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: count
instances:
  strings:
    type: string_at(_index)
    pos: 0
    repeat: expr
    repeat-expr: count
types:
  string_at:
    params:
      - id: index
        type: s4
    instances:
      value:
        pos: _root.offsets[index]
        type: strz
        encoding: UTF-8
        io: _root._io
