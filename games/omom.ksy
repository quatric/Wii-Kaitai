meta:
  id: omom
  title: OMOM quest data archive (Monster Hunter 3)
  endian: be
doc: |
  `OMOM` quest archive (Monster Hunter 3 tri- / G, Wii `quest/quest*.bin`).
  Members sit at 0x40-aligned offsets; the data starts at the first offset and
  the table in front of it is zero padded. Members carry no names.
seq:
  - id: magic
    contents: OMOM
  - id: num_entries
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: offset
        type: u4
      - id: len_data
        type: u4
    instances:
      data:
        pos: offset
        io: _root._io
        size: len_data
