meta:
  id: aix
  title: CRI AIX container (.aix)
  file-extension: aix
  endian: be
doc: |
  CRI `AIXF` container (Sonic Unleashed, Metroid: Other M). Behind the segment
  table sit a 0x10-byte sub-table (first byte 1) and the layer table, whose
  layer count is at +0x10. A segment is a run of `AIXP` chunks interleaving the
  layers, each an ADX stream; a chunk is `{id, u32 size - 8, s8 layer,
  u8 layer count, s16 data size, -1, data at +0x10}`.
seq:
  - id: magic
    contents: AIXF
  - id: len_header_minus_8
    type: u4
  - id: constant
    type: u4
    doc: 0x01000014.
  - id: alignment
    type: u4
    doc: 0x800.
  - id: reserved0
    size: 8
  - id: num_segments
    type: u2
  - id: reserved1
    size: 6
  - id: segments
    type: segment
    repeat: expr
    repeat-expr: num_segments
types:
  segment:
    seq:
      - id: offset
        type: u4
      - id: len_data
        type: u4
      - id: num_samples
        type: s4
      - id: sample_rate
        type: s4
    instances:
      data:
        pos: offset
        io: _root._io
        size: len_data
