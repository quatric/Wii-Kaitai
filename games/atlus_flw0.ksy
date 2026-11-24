meta:
  id: atlus_flw0
  title: Atlus FLW0 flow script (.bf)
  file-extension: bf
  endian: be
doc: |
  Atlus `FLW0` flow script (Trauma Team, Wii). Section types: 0 procedure
  labels, 1 jump labels (0x38-byte elements: name[0x20] ... instruction index at
  +0x30), 2 the instruction stream (u32 elements), 3 the embedded `MSG2`
  message block (0x30-byte header, then 0x40-byte records
  `{name[0x20], 0, text size, text offset, 0xffff0000, ...}` whose text blobs
  are a byte-coded stream with Shift-JIS strings) and 4 a string pool.
seq:
  - id: zero
    type: u4
  - id: len_file
    type: u4
  - id: magic
    contents: FLW0
  - id: zero2
    type: u4
  - id: num_sections
    type: u4
  - id: constant
    type: u4
    doc: 0x10000.
  - id: padding
    size: 8
  - id: sections
    type: section
    repeat: expr
    repeat-expr: num_sections
types:
  section:
    seq:
      - id: type
        type: u4
      - id: element_size
        type: u4
      - id: num_elements
        type: u4
      - id: offset
        type: u4
    instances:
      body:
        pos: offset
        io: _root._io
        size: element_size * num_elements
