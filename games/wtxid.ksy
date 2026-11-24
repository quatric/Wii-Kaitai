meta:
  id: wtxid
  title: WTXID object image (Cook Wars / Cooking Party / Petz Rescue)
  endian: be
doc: |
  Geom/*.wtxg models and Anim/*.wtxa animations. 0x80-byte header table of u32
  BE {offset/count} pairs, then a serialised C++ object heap (class and
  instance names as NUL-terminated strings with a length prefix) whose layout is
  game-specific and not decoded.
seq:
  - id: magic
    contents: WTXID
  - id: kind
    type: u1
    doc: "'g' geometry, 'a' animation."
  - id: version
    type: u2
    doc: 2.
  - id: flags
    type: u4
  - id: table
    type: pair
    repeat: expr
    repeat-expr: 15
  - id: heap
    size-eos: true
types:
  pair:
    seq:
      - id: offset_or_count
        type: u4
      - id: count_or_size
        type: u4
