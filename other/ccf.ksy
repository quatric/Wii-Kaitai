meta:
  id: ccf
  endian: be
  title: Wii Virtual Console CCF archive
doc: |
  Wii Virtual Console "CCF" flat archive, per lib-vc.c (WiiBrew
  "CCF archive" page, cross-checked against paulguy/ccf-tools).
  Optional per-entry zlib (standard, not raw-deflate) compression;
  a member is stored raw when size == decompressed_size.
seq:
  - id: magic
    contents: "CCF\0"
  - id: unknown_04
    size: 12
  - id: offset_multiplier
    type: u4
  - id: num_files
    type: u4
  - id: unknown_18
    size: 8
  - id: entries
    type: entry_t
    repeat: expr
    repeat-expr: num_files
types:
  entry_t:
    seq:
      - id: name
        type: str
        size: 20
        encoding: ASCII
        terminator: 0
      - id: offset_units
        type: u4
      - id: size
        type: u4
      - id: decompressed_size
        type: u4
    instances:
      offset:
        value: offset_units * _root.offset_multiplier
      body:
        pos: offset
        size: size
        io: _root._io
