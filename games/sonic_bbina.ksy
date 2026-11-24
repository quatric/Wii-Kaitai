meta:
  id: sonic_bbina
  title: Sonic Team BBINA header (Sonic Colors)
  endian: be
doc: |
  .orc / .anm / some .bin. Payload (relocated pointers etc.) follows the
  0x20-byte header; not modelled.
seq:
  - id: file_size
    type: u4
  - id: data_size
    type: u4
  - id: pointer_count
    type: u4
    doc: Not always exact.
  - id: zero0
    type: u4
  - id: zero1
    type: u4
  - id: zero2
    type: u2
  - id: version
    type: u2
    doc: 0x3142 ("1B").
  - id: bina
    contents: BINA
  - id: rest
    size: 4
  - id: body
    size-eos: true
