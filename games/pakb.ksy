meta:
  id: pakb
  title: "PAKb archive (Secret Files: Tunguska / Puritas Cordis)"
  file-extension: pak
  endian: be
doc: |
  `PAKb` archive (Secret Files: Tunguska / Puritas Cordis, Wii). Payloads
  follow back to back from `8 + count * 12`. Members are stored (THP movies, U8
  archives, `MINA`/`GE`/`func` data, ...). The last member is a name table of
  `{u32 hash, u32 length, name}` records sorted by hash, covering about 63% of
  the members.
seq:
  - id: magic
    contents: PAKb
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
      - id: len_data
        type: u4
