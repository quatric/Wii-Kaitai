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
seq:
  - id: table_bytes
    type: u4
    doc: Byte size of the whole offset table (== offsets[0].offset).
  - id: offsets
    type: offset_entry
    repeat: expr
    repeat-expr: table_bytes / 4
types:
  offset_entry:
    seq:
      - id: raw
        type: u4
    instances:
      offset:
        value: raw & 0x7fffffff
      flag:
        value: (raw & 0x80000000) != 0
