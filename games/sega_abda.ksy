meta:
  id: sega_abda
  title: SEGA ABDA block (Sakura Wars So Long My Love)
  file-extension: abd
  endian: le
doc: |
  ABDT object tree (pointers are absolute file offsets): root at section+0x10:
  7 header words, +0x1c count A, +0x20 pointer to A pointers to 3-word records,
  +0x24 count B, +0x28 pointer to B node pointers. Node: 15 header words, +0x30
  count C / +0x34 pointer, +0x40 count D / +0x44 child pointers. Child: 45
  header words, +0xb4 count E / +0xb8 leaf pointers. Leaf: 5 header words, +0x14
  count F / +0x18 pointers to 6-word records.
seq:
  - id: magic
    contents: ABDA
  - id: size
    type: u4
  - id: header_size
    type: u4
    doc: 0x30..0x140.
  - id: zero
    type: u4
  - id: type_hash
    type: u4
    doc: 0x77820d59 in most files.
  - id: section_count
    type: u4
  - id: pof0_offset
    type: u4
  - id: pad
    size: 4
  - id: sections
    type: section_ref
    repeat: expr
    repeat-expr: section_count
types:
  section_ref:
    seq:
      - id: offset
        type: u4
      - id: zero
        type: u4
    instances:
      section:
        pos: offset
        type: section
        io: _root._io
  section:
    seq:
      - id: tag
        size: 4
        type: str
        encoding: ASCII
      - id: payload_size
        type: u4
      - id: header_size
        type: u4
        doc: 0x10.
      - id: zero
        type: u4
      - id: payload
        size: payload_size
