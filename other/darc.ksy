meta:
  id: darc
  file-extension: darc
  endian: le
  title: Nintendo DARC directory archive
doc: |
  DARC ("Directory ARChive") is Nintendo's flat container for the 3DS/Wii U
  era, the sibling of Wii's U8 (`system/u8.ksy`) and the later SARC
  (`nw4c/sarc.ksy`): a header, a flat table of fixed-size entries, then a
  UTF-16LE string table, then the raw payloads. Modeled from
  `ScanDARC()`/`ResetDARC()` in nintoolbox's lib-darc.c.

  Unlike U8/SARC, entries here form a tree only implicitly: each entry
  knows its own name-table offset and either (file) an absolute data
  offset + size, or (directory) a parent-relative field and the index one
  past the end of its own subtree, mirroring U8's kind/parent/next-index
  scheme but keyed off bit 24 of the first field instead of a separate
  kind byte.

  Names are UTF-16LE, NUL-terminated, unlike U8/SARC's ASCII/UTF-8 -- the
  library carries its own UTF-16LE-to-UTF-8 decoder (`darc_utf16le_to_utf8`)
  with surrogate-pair handling because of this.
seq:
  - id: magic
    contents: "darc"
  - id: bom
    type: u2
    doc: Byte-order mark, always 0xfeff (little-endian) for files this library accepts.
  - id: header_size
    type: u2
    doc: Size of this header; must be >= 0x1c.
  - id: version
    type: u4
    doc: Unused by the scanner, but present at offset 8 per the known DARC layout.
  - id: file_size
    type: u4
    doc: Total file size.
  - id: table_offset
    type: u4
    doc: Offset of the entry table (the `n`-entry array below).
  - id: table_size
    type: u4
    doc: Size in bytes of the entry table region; table_size / 12 bounds the entry count.
instances:
  root_entry:
    pos: table_offset
    type: entry
    doc: |
      Entry 0. Its first field must have bit 0x01000000 set (it is always
      a directory) and its third field (`end_or_size`) doubles as the
      total live entry count for the whole table.
  n_entries:
    value: root_entry.end_or_size
  entries:
    pos: table_offset
    type: entry
    repeat: expr
    repeat-expr: n_entries
  name_area_offset:
    value: table_offset + n_entries * 12
    doc: Where the UTF-16LE name blob begins, immediately after the entry table.
types:
  entry:
    seq:
      - id: name_off_and_flag
        type: u4
        doc: |
          Low 24 bits: byte offset of this entry's name into the name
          area. Bit 24 (0x01000000): set for a directory, clear for a
          file.
      - id: parent_or_offset
        type: u4
        doc: |
          Directory: index of the parent directory entry.
          File: absolute byte offset of the file's data within the archive.
      - id: end_or_size
        type: u4
        doc: |
          Directory: index one past the last entry of this directory's
          subtree (root's is also the total entry count).
          File: byte size of the file's data.
    instances:
      is_dir:
        value: (name_off_and_flag & 0x01000000) != 0
      name_offset:
        value: name_off_and_flag & 0xffffff
      name:
        io: _root._io
        pos: _root.name_area_offset + name_offset
        type: str_utf16le
      body:
        io: _root._io
        pos: parent_or_offset
        size: end_or_size
        if: not is_dir
  str_utf16le:
    doc: |
      NUL-terminated UTF-16LE string, decoded here as raw u2 code units;
      lib-darc.c does its own surrogate-pair-aware conversion to UTF-8
      (`darc_utf16le_to_utf8`) which Kaitai has no direct equivalent for.
    seq:
      - id: units
        type: u2
        repeat: until
        repeat-until: _ == 0
