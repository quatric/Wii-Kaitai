meta:
  id: muramasa_nmsb
  title: Muramasa NMSB message sheet (.nms body)
  endian: le
doc: |
  `NMSB` block inside the `FCMP` LZSS container of Muramasa - The Demon Blade
  `.nms` message sheets (Wii). `count` u32 slots (zero on disc, filled in at load
  time) are followed by the NUL-terminated strings in index order (Shift-JIS in
  the Japanese sheets, Latin-1 in the European ones; the pool can hold a few
  extra trailing strings).
seq:
  - id: magic
    contents: NMSB
  - id: len_payload
    type: u4
  - id: header_size
    type: u4
    doc: 0x20.
  - id: zero0
    type: u4
  - id: zero1
    type: u4
  - id: num_strings
    type: u4
  - id: reserved
    size: 8
  - id: slots
    type: u4
    repeat: expr
    repeat-expr: num_strings
