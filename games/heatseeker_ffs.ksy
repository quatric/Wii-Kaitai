meta:
  id: heatseeker_ffs
  title: Heatseeker FFS sound archive (.ffs)
  file-extension: ffs
  endian: le
doc: |
  Heatseeker (Wii) `Sound/Wii/*.ffs` archive. A directory of entries, each
  with its length-prefixed name, file offset and size; the payloads (FMOD
  `FSB3` banks and small `.DAT` tables) are stored back to back after the
  directory.
seq:
  - id: magic
    contents: 'FFS '
  - id: num_entries
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: len_name
        type: u4
      - id: name
        type: str
        size: len_name
        encoding: ASCII
      - id: offset
        type: u4
      - id: len_data
        type: u4
    instances:
      data:
        pos: offset
        io: _root._io
        size: len_data
