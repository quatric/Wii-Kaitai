meta:
  id: wwb
  title: Marines Modern Urban Combat .wwb sound bank
  file-extension: wwb
  endian: le
doc: Members have a 28-byte header {u32, samples, rate, 0, 2, u32, 2} then ADPCM.
seq:
  - id: count
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
