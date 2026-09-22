meta:
  id: agi
  file-extension: pak
  endian: be
  title: Toys for Bob AGI archive
doc: |
  A flat archive used by Toys for Bob titles (audio banks and mixed
  audio+model `.pak` files). A fixed 0x40-byte header gives the size of
  a variable-layout entry table and the location of a fixed-layout name
  table; the entry table's own record shape is not fixed by the format
  itself -- it is either a sequence of 2-word (offset, size) pairs (pure
  audio banks) or 4-word records (mixed audio+model banks, whose third
  word cannot be trusted as an on-disk size) and must be told apart
  heuristically. The entry table is therefore exposed as big-endian words,
  without assigning one misleading fixed record type to every file.

  ScanAGI first scans adjacent words for plausible absolute (offset,size)
  pairs and accepts that layout only if it finds exactly num_names pairs.
  Otherwise it searches for num_names consecutive four-word records with
  word0 zero and word1 an absolute 0x800-aligned offset before the name
  table. In the latter layout, word2 is not a reliable stored byte length;
  raw payload boundaries come from the next distinct offset in ascending
  order, or the name table for the last one. Word3 is a per-entry flag,
  observed as 0xffffffff for small stubs or 0x2000000x otherwise. The
  choice of layout and derived member lengths are not implemented here.

  The scanner requires 1..0x100000 names, a complete entry table, and a
  name table ending exactly at EOF. Name offsets are relative to the name
  table itself. Each name is a NUL-terminated backslash-separated path
  followed by four hash/CRC bytes of unknown purpose. Extraction uses only
  its final path component, substitutes an ordinal .bin name for invalid
  basenames, and appends .fsb to raw FSB5 members lacking that extension.
seq:
  - id: magic
    contents: [0x1a, 0x41, 0x47, 0x49]
  - id: version
    type: u4
    doc: Version; 9 in the documented retail samples.
  - id: len_entry_table
    type: u4
    doc: Byte length of the variable-layout table starting at 0x40.
  - id: num_names
    type: u4
    doc: Number of members; also the number of entries in the name-offset table.
  - id: block_align
    type: u4
    doc: Data block alignment; 0x800 in the documented samples.
  - id: table_hash
    type: u4
    doc: Table hash or checksum field; exact algorithm unknown.
  - id: unknown_18
    type: u4
    doc: Header word of unknown purpose.
  - id: reserved_1c
    size: 0x10
    doc: Four reserved header words; zero in documented samples.
  - id: ofs_name_table
    type: u4
    doc: Absolute offset of the name table; verified to always land the table's end exactly at EOF.
  - id: len_name_table
    type: u4
    doc: Byte length of name table; its end coincides with EOF in known samples.
  - id: unknown_34
    type: u4
    doc: Header word whose observed value is 3; meaning unknown.
  - id: hash_38
    type: u4
    doc: Hash-like header word; algorithm unknown.
  - id: hash_3c
    type: u4
    doc: Second hash-like header word; algorithm unknown.
  - id: entry_table
    type: entry_table_t
    size: len_entry_table
    doc: |
      Raw big-endian words for either entry layout. A non-word-aligned
      trailing byte count is not interpreted by the scanner.
instances:
  name_table:
    io: _root._io
    pos: ofs_name_table
    size: len_name_table
    type: name_table_t(num_names)
types:
  entry_table_t:
    seq:
      - id: words
        type: u4
        repeat: expr
        repeat-expr: _root.len_entry_table / 4
        doc: Words scanned for pairs or aligned four-word records by nintoolbox.
  name_table_t:
    params:
      - id: count
        type: u4
    seq:
      - id: names
        type: name_ref_t
        repeat: expr
        repeat-expr: count
        doc: |
          Name references in member order. Each referenced string is
          followed by four ignored hash/CRC bytes.
  name_ref_t:
    seq:
      - id: offset
        type: u4
        doc: Byte offset of a NUL-terminated path relative to the name table.
    instances:
      path:
        pos: offset
        type: str
        encoding: ASCII
        terminator: 0
        io: _parent._io
        doc: Backslash-separated source path; extraction uses its basename.
