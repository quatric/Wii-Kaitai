meta:
  id: nccarc
  endian: le
  title: NCC flat offset-table archive
doc: |
  A minimal flat archive container, as read by ScanNCCARC() in
  lib-nccarc.c: an offset table of `n` little-endian 32-bit values
  (the high bit of each is a per-entry flag), where `off[0]` equals
  the table's own byte size and `off[n-1]` equals the file size;
  member `i` spans `off[i] .. off[i+1]` bytes right after the table.
  No text magic identifies the format; detection is purely structural
  (monotonic offsets bounded by the file size).

  The first offset word is also the table byte length: it must be nonzero,
  divisible by four, and no greater than the file size. There must be
  2..0x40000 offset words, yielding one fewer members. The reader masks off
  the high bit before checking that offsets are nondecreasing, that the
  first equals the table size, and that the last equals EOF. It associates
  each member with the flag on its starting offset; the terminal offset's
  flag has no corresponding member. Equal adjacent offsets represent an
  empty member. There are no stored names or compression instructions.

  The nintoolbox writer emits at most 65535 members, clears every flag,
  and packs bodies consecutively after the offset table. It does not
  preserve source flags. This writer limit is narrower than the reader's
  0x3ffff-member maximum.
seq:
  - id: table_bytes
    type: u4
    doc: First offset word and byte size of the entire table; not a separate header.
instances:
  offsets:
    pos: 0
    type: offset_entry(_index)
    repeat: expr
    repeat-expr: table_bytes / 4
    doc: Complete offset array, including the already-read table_bytes word.
types:
  offset_entry:
    params:
      - id: index
        type: u4
    seq:
      - id: raw
        type: u4
        doc: Offset in low 31 bits; high bit flags the member beginning here.
    instances:
      offset:
        value: raw & 0x7fffffff
        doc: Absolute byte offset after masking the flag bit.
      flag:
        value: (raw & 0x80000000) != 0
        doc: Per-member flag; not meaningful on the terminal offset.
      body:
        io: _root._io
        pos: offset
        size: _root.offsets[index + 1].offset - offset
        if: index < _root.table_bytes / 4 - 1
        doc: Raw member bytes up to the next masked offset; empty spans are valid.
