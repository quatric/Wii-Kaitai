meta:
  id: wadh
  endian: le
  title: Data Design Interactive WADH game archive
doc: |
  Data Design Interactive "WADH" game archive (DataWII.wad in
  Ninjabread Man), per lib-wadh.h. Not related to Wii channel WADs.
  Directories are entries with size == 0 and last_child != 0xffffffff.

  The 16-byte header is followed by num_entries 32-byte descriptors;
  the name table then extends from the descriptor-table end to data_base.
  Member offsets are relative to data_base. The scanner ignores the
  header's names_size value and derives the actual name-region length
  from data_base instead. The table may include padding after the last
  NUL-terminated name. Entry zero is an anonymous root.

  Directory children are discovered by walking last_child and then
  prev_sibling backward to the first sibling. The scanner rejects an
  out-of-range child index, cycles, or a child assigned to two parents.
  It builds paths by following parent links toward entry zero, with a
  maximum depth of 64. Unparented non-root entries are skipped. Invalid
  or too-long paths are replaced with NNNN.bin, and duplicate paths gain
  a numeric suffix. Every included file's data range must be inside EOF;
  size2, name_hash, and flags are preserved fields but not validated by
  the scanner. At least one file must survive for recognition.
seq:
  - id: magic
    contents: "WADH"
  - id: data_base
    type: u4
    doc: Size of header + directory + name table; member offsets are relative to this.
  - id: num_entries
    type: u4
    doc: Descriptor count including root; scanner accepts 2..0x100000.
  - id: names_size
    type: u4
    doc: Recorded name-table length; scanner ignores it and derives length from data_base.
  - id: entries
    type: entry_t
    repeat: expr
    repeat-expr: num_entries
  - id: names
    size: data_base - (0x10 + num_entries * 32)
    doc: NUL-separated paths plus possible padding up to the payload base.
types:
  entry_t:
    doc: Entry 0 is the anonymous root.
    seq:
      - id: name_offset
        type: u4
        doc: Offset relative to the name table; 0xffffffff for the root.
      - id: name_hash
        type: u4
        doc: Stored name hash; scanner does not check it.
      - id: offset
        type: u4
        doc: Files only; relative to data_base.
      - id: size
        type: u4
        doc: Raw member byte length; zero with a child link indicates a directory.
      - id: size2
        type: u4
        doc: Nominal duplicate of size; scanner does not verify equality.
      - id: flags
        type: u4
        doc: Per-entry flags of unknown meaning, ignored by the scanner.
      - id: last_child
        type: u4
        doc: Directories -- index of the last child; files -- 0xffffffff.
      - id: prev_sibling
        type: u4
        doc: Index of the previous entry in the same directory, 0xffffffff for the first.
    instances:
      name:
        io: _root._io
        pos: 0x10 + _root.num_entries * 32 + name_offset
        type: str
        encoding: ASCII
        terminator: 0
        if: name_offset != 0xffffffff
        doc: Name component, not a complete path; parent links supply directories.
      body:
        io: _root._io
        pos: _root.data_base + offset
        size: size
        if: size > 0 or last_child == 0xffffffff
        doc: Raw file bytes addressed relative to data_base.
