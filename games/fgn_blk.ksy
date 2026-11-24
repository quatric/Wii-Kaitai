meta:
  id: fgn_blk
  title: Family Game Night 4 block file (.blk)
  file-extension: blk
  endian: be
doc: |
  Family Game Night 4 `blockfiles/*.blk`. A 0x20-byte header, then the file
  table of 0x9C-byte entries. Member data starts at the end of the table
  rounded up to 0x20; members follow each other (0x20 aligned) to the end of
  the file.
seq:
  - id: version
    type: u2
    doc: 1.
  - id: version2
    type: u2
    doc: 1.
  - id: num_files
    type: u2
  - id: header_rest
    size: 0x1a
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_files
types:
  entry:
    seq:
      - id: name
        size: 0x80
        type: strz
        encoding: ASCII
        doc: Path with `/` separators.
      - id: offset
        type: u4
      - id: len_data
        type: u4
      - id: flags
        type: u4
      - id: hash
        size: 16
    instances:
      data:
        pos: offset
        io: _root._io
        size: len_data
