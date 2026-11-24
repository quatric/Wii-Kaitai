meta:
  id: acx_hst
  title: Samurai Shodown Anthology sound bank (.acx)
  file-extension: acx
  endian: be
doc: |
  Samurai Shodown Anthology `*.acx` sound bank. The data follows the table and
  ends at about the end of the file.
seq:
  - id: zero
    type: u4
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
      - id: len_data
        type: u4
    instances:
      data:
        pos: offset
        io: _root._io
        size: len_data
