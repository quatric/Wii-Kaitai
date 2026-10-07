meta:
  id: xpk
  title: Exient XPK archive (Angry Birds Star Wars .pak)
  file-extension: pak
  endian: be
doc: |
  Exient's `XPK` archives (Angry Birds Star Wars, Wii). Worked out from the four
  retail packages (scripts, levels, extras, images: 29..411 entries); every
  zlib member inflates to exactly its recorded size.

  The entry count is not in the header: the first file's data starts exactly
  where the name table ends, so `entries = (min file offset - names_size - 0x50)
  / 32`. A directory owns the contiguous entry range `[first child, first child
  + count)`; entries outside every range sit at the root, and ranges may
  contain further directories. Directory records come first.

  Entry `flags`: 1 = zlib stream, 0 = stored (or a directory).
seq:
  - id: magic
    contents: [0x58, 0x50, 0x4b, 0x01]
    doc: '`XPK` 0x01.'
  - id: version
    type: u4
    doc: 2, 3, 4 and 9 seen; layout identical.
  - id: num_files
    type: u4
    doc: Number of file entries (directory records are extra).
  - id: names_size
    type: u4
  - id: counters
    size: 0x40
    doc: Counters and zeros, not needed.
  - id: leading_entries
    type: entry
    repeat: until
    repeat-until: _.size != 0
    doc: |
      Directory records (size 0) followed by the first file record, which is
      the last element of this array. Its `offset` is the end of the name
      table, which fixes the total entry count.
  - id: trailing_entries
    type: entry
    repeat: expr
    repeat-expr: num_entries - leading_entries.size
  - id: names
    size: names_size
    doc: NUL-separated name table.
instances:
  num_entries:
    value: (leading_entries.last.offset - names_size - 0x50) / 32
    doc: Total number of entry records, directories included.
types:
  entry:
    seq:
      - id: zero_00
        type: u4
      - id: name_offset
        type: u4
        doc: Offset into the name table.
      - id: size
        type: u4
        doc: Uncompressed size; 0 marks a directory.
      - id: offset
        type: u4
        doc: File - absolute data offset; directory - index of its first child entry.
      - id: flags
        type: u4
      - id: mtime
        type: u4
      - id: csize
        type: u4
        doc: |
          File - stored/compressed length (0 for stored files, whose length is
          `size`); directory - number of children.
      - id: zero_1c
        type: u4
