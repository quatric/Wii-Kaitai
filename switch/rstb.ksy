meta:
  id: rstb
  endian: le
  title: Zelda BOTW/TOTK Resource Size Table (RSTB)
doc: |
  BOTW/TOTK Resource Size Table, per lib-rstb.c. Flat crc32+name size
  lookup, no relocations -- the whole file length is known up front
  from the two header counts.
  Reference: zeldamods.org/wiki/ResourceSizeTable.product.rsizetable
seq:
  - id: magic
    contents: "RSTB"
  - id: crc_count
    type: u4
  - id: name_count
    type: u4
  - id: crc_entries
    type: crc_entry
    repeat: expr
    repeat-expr: crc_count
  - id: name_entries
    type: name_entry
    repeat: expr
    repeat-expr: name_count
types:
  crc_entry:
    seq:
      - id: crc32
        type: u4
      - id: size
        type: u4
  name_entry:
    seq:
      - id: name
        type: str
        size: 128
        encoding: ASCII
        terminator: 0
      - id: size
        type: u4
