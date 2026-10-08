meta:
  id: shade_bin
  title: Shade / Level-5 Inazuma Eleven Strikers .bin container
  file-extension: bin
  endian: le
doc: |
  Shade / Level-5 container used by Inazuma Eleven Strikers (`grp`, `scn`,
  `scn_sh`, `ui`, `dat`, `strap` `.bin`). Header: `count`, `pad`, `mult`,
  `shift`, `mask`, then `count` words at 0x14. For each word `v`:
  `offset = (v >> shift) * pad` and `size = (v & mask) * mult` (rounded up to
  `pad`). Members are ShadeLz data (see `shade_lz.ksy`).
seq:
  - id: count
    type: u4
  - id: pad
    type: u4
  - id: mult
    type: u4
  - id: shift
    type: u4
  - id: mask
    type: u4
  - id: words
    type: u4
    repeat: expr
    repeat-expr: count
instances:
  members:
    type: member_at(words[_index])
    pos: 0
    repeat: expr
    repeat-expr: count
types:
  member_at:
    params:
      - id: word
        type: u4
    instances:
      offset:
        value: (word >> _root.shift) * _root.pad
      size:
        value: (word & _root.mask) * _root.mult
      data:
        pos: offset
        size: size
        io: _root._io
