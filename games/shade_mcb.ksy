meta:
  id: shade_mcb
  title: Shade / Level-5 Strikers mcb0.bln index
  file-extension: bln
  endian: le
doc: |
  `mcb0.bln` of Inazuma Eleven Strikers: 4096 records `{u4 id, u4 offset, u4
  size}`. Each `(offset, size)` range inside `mcb1.bln` holds
  `{u4 archive, u4 archive_offset, u4 size}` followed by ShadeLz data
  (see `shade_lz.ksy`), repeated until the end of the range or a `0x7fff`
  marker.
seq:
  - id: records
    type: record
    repeat: expr
    repeat-expr: 4096
types:
  record:
    seq:
      - id: id
        type: u4
      - id: offset
        type: u4
        doc: Offset into `mcb1.bln`.
      - id: size
        type: u4
