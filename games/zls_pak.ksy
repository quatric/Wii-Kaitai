meta:
  id: zls_pak
  title: "Hash-indexed PAK (Kid Adventures: Sky Captain)"
  file-extension: dat
  endian: be
doc: |
  Hash-indexed `PAK\0` package (Kid Adventures: Sky Captain
  `packfile/packfile.dat`), records sorted by hash (the hash algorithm is
  unknown). A member is either stored or `!ZLS`, a little-endian u32 unpacked
  size and a zlib stream.
seq:
  - id: magic
    contents: ['PAK', 0]
  - id: num_entries
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: name_hash
        type: u4
      - id: offset
        type: u4
        doc: Absolute.
      - id: len_data
        type: u4
