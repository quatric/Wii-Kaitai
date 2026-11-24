meta:
  id: sgcaudio
  title: Racquet Sports .SGC speech bank
  file-extension: sgc
  endian: be
doc: Samples are unsigned 8-bit mono PCM.
seq:
  - id: one
    type: u2
  - id: id
    type: u2
  - id: count
    type: u4
  - id: zero
    size: 8
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: name_hash
        type: u4
      - id: sample_rate
        type: u2
      - id: bits_flag
        type: u2
        doc: 0x0800 = 8 bit.
      - id: offset
        type: u4
      - id: size
        type: u4
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
