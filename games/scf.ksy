meta:
  id: scf
  title: Roogoo Twisted Towers DataFiles.scf
  file-extension: scf
  endian: le
doc: |
  Roogoo - Twisted Towers `DataFiles.scf`: a byte 1, then repeated `{name NUL,
  le32 compressed size, zlib stream}`; the last stream ends exactly at the end of
  the file.
seq:
  - id: one
    type: u1
  - id: members
    type: member
    repeat: eos
types:
  member:
    seq:
      - id: name
        type: strz
        encoding: ASCII
      - id: len_compressed
        type: u4
      - id: zlib_stream
        size: len_compressed
