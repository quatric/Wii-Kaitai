meta:
  id: dc2_dcx
  file-extension: dcx
  endian: be
  title: DC2 engine directory archive (Jakers! Kart Racing, Wii)
doc: |
  Little more than a flat directory for the DC2 engine used by Jakers!
  Kart Racing (Wii). Every field is big-endian: an entry count, then that
  many `(name_len, name, offset, size)` records with backslash path
  separators, followed immediately by the member payloads back to back.
  There is no magic -- the format is only identified by the directory
  chaining exactly from its own end to the end of the file (each member's
  `ofs_body` must equal the previous member's end, and the last member
  must end exactly at EOF).

  See `dc2_dct.ksy` for the "DC2\0"-tagged texture format stored inside
  these archives.
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
      - id: len_name
        type: u4
      - id: name
        type: str
        size: len_name
        encoding: ASCII
        doc: Relative path using backslash separators.
      - id: ofs_body
        type: u4
        doc: Absolute offset of this member's data.
      - id: len_body
        type: u4
    instances:
      body:
        io: _root._io
        pos: ofs_body
        size: len_body
