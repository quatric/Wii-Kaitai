meta:
  id: vtb
  title: Batman Brave and the Bold .vtb vertex buffers
  file-extension: vtb
  endian: be
doc: |
  Each slot is one Nintendo LZ11 stream (decoded up to 64 KiB) of raw
  vertex/index data. Blocks are back to back from `header_size`.
seq:
  - id: header_size
    type: u4
  - id: a
    type: u4
  - id: b
    type: u4
  - id: descriptor_offsets
    type: u4
    repeat: expr
    repeat-expr: a * b
    doc: 0 = unused.
types:
  descriptor:
    seq:
      - id: data_offset
        type: u4
      - id: data_size
        type: u4
      - id: slots
        type: slot
        repeat: expr
        repeat-expr: 16
  slot:
    seq:
      - id: start
        type: u4
        doc: Relative to the block's data offset.
      - id: size
        type: u4
        doc: 0 = unused.
