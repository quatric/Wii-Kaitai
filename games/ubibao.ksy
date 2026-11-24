meta:
  id: ubibao
  title: Ubisoft DARE sound package (.pk / .lpk)
  file-extension: pk
  endian: le
doc: |
  Rayman Raving Rabbids TV Party, Just Dance, Avatar, Prince of Persia
  Forgotten Sands (after vgmstream ubi_bao). At 0x40: index_size / 8 {id, size}
  pairs, then big-endian BAOs back to back. Resource table: u32 count, u32
  string size, strings, then {id, name offset, offset, size} for external
  streams. A BAO is {u32 version, ..., u32 class @0x20}.
seq:
  - id: one
    type: u1
  - id: version
    type: b24le
  - id: index_size
    type: u4
  - id: resource_table_offset
    type: u4
  - id: pad
    size: 0x34
  - id: index
    type: pair
    repeat: expr
    repeat-expr: index_size / 8
instances:
  resource_table:
    pos: resource_table_offset
    type: resource_table
types:
  pair:
    seq:
      - id: id
        type: u4
      - id: size
        type: u4
  resource_table:
    seq:
      - id: count
        type: u4
      - id: string_size
        type: u4
      - id: strings
        size: string_size
      - id: entries
        type: res
        repeat: expr
        repeat-expr: count
  res:
    seq:
      - id: id
        type: u4
      - id: name_offset
        type: u4
      - id: offset
        type: u4
      - id: size
        type: u4
