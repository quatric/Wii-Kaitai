meta:
  id: brawl_arc
  title: Super Smash Bros. Brawl fighter pack
  endian: be
doc: |
  Super Smash Bros. Brawl fighter pack (`FitXXX00.pcs`, LZ10-compressed first,
  then this container; not the Nintendo U8 `.arc`). Members are BRRES for types
  1-3.
seq:
  - id: magic
    contents: ['ARC', 0]
  - id: version
    type: u2
    doc: 0x0101.
  - id: num_members
    type: u2
  - id: reserved0
    size: 8
  - id: name
    size: 16
    type: strz
    encoding: ASCII
  - id: reserved1
    size: 0x30
  - id: members
    type: member
    repeat: expr
    repeat-expr: num_members
types:
  member:
    seq:
      - id: type
        type: u2
      - id: group
        type: u2
      - id: len_data
        type: u4
      - id: reserved
        size: 0x18
      - id: data
        size: len_data
