meta:
  id: mama_pkb
  title: Cooking / Babysitting Mama resource pack (.pkb)
  file-extension: pkb
  endian: be
doc: |
  Cooking Mama / Babysitting Mama (Wii, Office Create) `pack/*.pkb`. Eight
  identical u32 member counts, then 0x40-byte records. The first payload
  starts after the table (aligned); members follow back to back with
  alignment gaps. Names may contain a sub folder (`stage/st0009`).
seq:
  - id: counts
    type: u4
    repeat: expr
    repeat-expr: 8
    doc: All eight are the member count.
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: counts[0]
types:
  entry:
    seq:
      - id: offset
        type: u4
      - id: len_data
        type: u4
      - id: kind
        type: u4
        enum: kind
      - id: zero
        type: u4
      - id: name
        size: 48
        type: strz
        encoding: ASCII
    instances:
      data:
        pos: offset
        io: _root._io
        size: len_data
enums:
  kind:
    1: u8_archive
    2: brres
