meta:
  id: vaps
  title: vaps page set (Papaya Studio engine)
  file-extension: wii
  endian: be
doc: |
  Toy Story Mania!, Disney Princess Enchanted Journey etc. Entries are
  {hash, size, offset}, 12 bytes each, right after the bucket array; offsets
  are relative to the data base and members sit on 0x800 boundaries. Members
  carry no names; about a fifth start with a 0x00010000 header
  {version, class code, hash, class code, 0, 0}.
seq:
  - id: magic
    contents: vaps
  - id: version
    type: u4
    doc: 0x00010003.
  - id: entry_count
    type: u4
  - id: words3_6
    type: u4
    repeat: expr
    repeat-expr: 4
  - id: data_base
    type: u4
    doc: Page size, 0x800 or 0x2000.
  - id: words8_9
    type: u4
    repeat: expr
    repeat-expr: 2
  - id: bucket_size
    type: u4
  - id: bucket_offset
    type: u4
instances:
  entries:
    pos: bucket_offset + bucket_size
    type: entry
    repeat: expr
    repeat-expr: entry_count
types:
  entry:
    seq:
      - id: hash
        type: u4
      - id: size
        type: u4
      - id: offset
        type: u4
    instances:
      body:
        pos: _root.data_base + offset
        size: size
        io: _root._io
