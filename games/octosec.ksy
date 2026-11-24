meta:
  id: octosec
  title: Octomania secB scene / demo container (.sec)
  file-extension: sec
  endian: be
doc: |
  Header {"secB", u32 1, u32 data start (0x800), u32 table size, u32 alignment,
  ...} + a table of records and a name pool; payload is NW4R files on 0x800
  boundaries, either stored or packed with a token stream (b < 0x80 = b
  literal bytes, b >= 0x80 = (b & 0x7f) + 1 copies of the next byte).
seq:
  - id: magic
    contents: secB
  - id: one
    type: u4
  - id: data_start
    type: u4
    doc: 0x800.
  - id: table_size
    type: u4
  - id: alignment
    type: u4
  - id: rest
    size-eos: true
