meta:
  id: ws49pak
  title: 49Games .pak (Summer/Winter Athletics)
  file-extension: pak
  endian: le
doc: |
  Members with stored_size == unpacked_size are raw; the rest use an
  unidentified bit-packed codec.
seq:
  - id: magic
    contents: [0xef, 0xbe, 0xad, 0xde]
  - id: count
    type: u4
  - id: index_end
    type: u4
    doc: 0x14 + count * 40.
  - id: one
    type: u4
  - id: zero
    type: u4
  - id: records
    type: record
    repeat: expr
    repeat-expr: count
types:
  record:
    seq:
      - id: hash
        type: u4
      - id: unk4
        type: u4
      - id: offset
        type: u4
      - id: zero0
        type: u4
      - id: stored_size
        type: u4
      - id: zero1
        type: u4
      - id: unpacked_size
        type: u4
      - id: zero2
        type: u4
      - id: unk20
        type: u4
      - id: zero3
        type: u4
