meta:
  id: rcf
  title: Radical Entertainment ATG Cement Library (.rcf)
  file-extension: rcf
  endian: be
doc: |
  Radical Entertainment's "ATG CORE CEMENT LIBRARY" (Crash of the Titans,
  Wii). The older "RADCORE CEMENT LIBRARY" 1.2 (The Simpsons: Hit & Run) is a
  different layout and is not covered. Verified on the seven Wii `.rcf` files
  (953 to 6947 members each): members lie inside the file and tile the data
  area exactly with 0x800 alignment, hashes ascend, and name extensions
  agree with member magics.

  Header and table fields are big-endian; the names block is little-endian.
  The i-th name belongs to the entry with the i-th smallest file offset.
  The name hash function was not identified.
seq:
  - id: magic
    size: 32
    doc: '`ATG CORE CEMENT LIBRARY`, NUL padded.'
  - id: version
    size: 4
    doc: '`02 01 01 01`.'
  - id: table_offset
    type: u4
    doc: Always 0x3c.
  - id: table_part_end
    type: u4
    doc: End of the first part of the table (not needed).
  - id: names_offset
    type: u4
    doc: Names block start; also the start of the pre-data padding.
  - id: names_length
    type: u4
  - id: zero_34
    type: u4
  - id: num_entries
    type: u4
instances:
  table:
    pos: table_offset
    type: entry
    repeat: expr
    repeat-expr: num_entries
  names:
    pos: names_offset
    type: names_block
    size: names_length
types:
  entry:
    seq:
      - id: name_hash
        type: u4
      - id: offset
        type: u4
        doc: Multiple of 0x800.
      - id: size
        type: u4
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
  names_block:
    seq:
      - id: header
        size: 8
        doc: 'Little-endian `0x800`, then 0.'
      - id: records
        type: name_record
        repeat: expr
        repeat-expr: _root.num_entries
  name_record:
    meta:
      endian: le
    seq:
      - id: mtime
        type: u4
        doc: Unix time.
      - id: align
        type: u4
        doc: Always 0x800.
      - id: zero
        type: u4
      - id: name_len
        type: u4
      - id: name
        type: strz
        size: name_len
        encoding: ASCII
        doc: Backslash-separated path; length includes the NUL.
      - id: padding
        size: 3
