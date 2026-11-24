meta:
  id: rkv2
  title: Krome RKV2 archive (.rkv)
  file-extension: rkv
  endian: le
doc: |
  Krome `RKV2` archive (Star Wars: The Force Unleashed, Wii). The file starts with
  two identical 0x40-byte headers. The table at `toc_offset` holds `count`
  20-byte records followed by the NUL-separated names; members are stored plain.
seq:
  - id: magic
    contents: RKV2
  - id: count
    type: u4
  - id: name_table_value
    type: u4
  - id: count_again
    type: u4
  - id: unknown
    type: u4
  - id: toc_offset
    type: u4
    doc: 0x14.
  - id: len_toc
    type: u4
    doc: 0x18.
instances:
  records:
    pos: toc_offset
    type: record
    repeat: expr
    repeat-expr: count
types:
  record:
    seq:
      - id: name_offset
        type: u4
      - id: zero
        type: u4
      - id: len_data
        type: u4
      - id: data_offset
        type: u4
      - id: name_hash
        type: u4
