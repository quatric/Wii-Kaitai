meta:
  id: zdat
  endian: le
  title: Animal Crossing Pocket Camp asset container (.zdat)
doc: |
  Animal Crossing: Pocket Camp ".zdat" flat container, per
  lib-zdat.c. Every payload is a Unity asset bundle XORed with one
  repeated byte recoverable from its own "UnityFS" signature; the
  XOR itself is not undone here.
seq:
  - id: magic
    contents: "ZDAT"
  - id: unknown_04
    size: 2
  - id: entry_table_offset
    type: u2
    doc: Always 0x20.
  - id: unknown_08
    size: 2
  - id: name_table_offset
    type: u2
  - id: unknown_0c
    size: 2
  - id: data_offset
    type: u2
  - id: unknown_10
    size: 2
  - id: num_entries
    type: u2
  - id: unknown_14
    size: 0x20 - 0x14
  - id: entries
    type: entry_t
    repeat: expr
    repeat-expr: num_entries
types:
  entry_t:
    seq:
      - id: name_length
        type: u4
      - id: size
        type: u4
      - id: uncompressed_size
        type: u4
      - id: unknown_0c
        type: u4
        doc: Always zero.
