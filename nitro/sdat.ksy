meta:
  id: sdat
  endian: le
  title: Nintendo DS Nitro SDAT sound archive
doc: |
  Nintendo DS "SDAT" sound archive, per lib-sdat.c. The header holds
  block-relative SYMB/INFO offsets and an absolute FAT offset. Only
  the FAT (flat file table) and the fixed header fields are modeled;
  the SYMB/INFO symbol-lookup blocks use a variable per-category
  offset scheme (per UnpackSDAT()) and are left raw.
seq:
  - id: magic
    contents: "SDAT"
  - id: unknown_04
    size: 0x10 - 4
  - id: symb_offset
    type: u4
  - id: symb_size
    type: u4
  - id: info_offset
    type: u4
  - id: info_size
    type: u4
  - id: fat_offset
    type: u4
  - id: fat_size
    type: u4
  - id: file_offset
    type: u4
  - id: file_size
    type: u4
  - id: unknown_30
    size: 0x40 - 0x30
instances:
  fat:
    pos: fat_offset
    type: fat_block
    io: _io
types:
  fat_block:
    seq:
      - id: magic
        contents: "FAT "
      - id: block_size
        type: u4
      - id: num_files
        type: u4
      - id: entries
        type: fat_entry
        repeat: expr
        repeat-expr: num_files
  fat_entry:
    seq:
      - id: offset
        type: u4
      - id: length
        type: u4
      - id: unknown_08
        type: u4
      - id: unknown_0c
        type: u4
    instances:
      body:
        pos: offset
        size: length
        io: _root._io
