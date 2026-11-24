meta:
  id: rubiks_ma
  title: Rubik's Puzzle World archive (.ma)
  file-extension: ma
  endian: le
doc: |
  Rubik's Puzzle World (Wii) `.ma` archive. A directory of entries with
  length-prefixed (NUL included) paths; the members are stored back to back at
  their offsets, 16-byte aligned.
seq:
  - id: num_entries
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: len_path
        type: u2
        doc: Includes the terminating NUL.
      - id: path
        type: strz
        size: len_path
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
