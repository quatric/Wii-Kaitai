meta:
  id: uocc
  title: Samba de Amigo challenge table
  file-extension: bin
  endian: be
seq:
  - id: blocks
    type: block
    repeat: eos
types:
  block:
    seq:
      - id: magic
        contents: UOCC
      - id: block_size
        type: u4
        doc: 0x58 with 5 items.
      - id: item_count
        type: u2
      - id: block_index
        type: u2
      - id: items
        type: item
        repeat: expr
        repeat-expr: item_count
      - id: end_tag
        contents: DNEC
    doc: Block = 12 header bytes + count * 16 - 4.
  item:
    seq:
      - id: ivd
        contents: IVD
      - id: a
        type: u1
      - id: b
        type: u1
      - id: c
        type: u1
      - id: d
        type: u1
      - id: x
        type: u4
      - id: y
        type: u4
      - id: pad
        type: u1
