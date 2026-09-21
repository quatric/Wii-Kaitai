meta:
  id: wadh
  endian: le
  title: Data Design Interactive WADH game archive
doc: |
  Data Design Interactive "WADH" game archive (DataWII.wad in
  Ninjabread Man), per lib-wadh.h. Not related to Wii channel WADs.
  Directories are entries with size == 0 and last_child != 0xffffffff.
seq:
  - id: magic
    contents: "WADH"
  - id: data_base
    type: u4
    doc: Size of header + directory + name table; member offsets are relative to this.
  - id: num_entries
    type: u4
  - id: names_size
    type: u4
  - id: entries
    type: entry_t
    repeat: expr
    repeat-expr: num_entries
  - id: names
    size: names_size
    doc: NUL-separated name table.
types:
  entry_t:
    doc: Entry 0 is the anonymous root.
    seq:
      - id: name_offset
        type: u4
        doc: 0xffffffff for the root.
      - id: name_hash
        type: u4
      - id: offset
        type: u4
        doc: Files only; relative to data_base.
      - id: size
        type: u4
      - id: size2
        type: u4
        doc: Always equal to size; members are stored uncompressed.
      - id: flags
        type: u4
      - id: last_child
        type: u4
        doc: Directories -- index of the last child; files -- 0xffffffff.
      - id: prev_sibling
        type: u4
        doc: Index of the previous entry in the same directory, 0xffffffff for the first.
