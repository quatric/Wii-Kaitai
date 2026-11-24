meta:
  id: nxms
  title: Arika NXMS (.nxms, Tetris the Grand Master 4)
  file-extension: nxms
  endian: le
doc: Every segment is a standard Switch Opus file.
seq:
  - id: magic
    size: 4
  - id: unk4
    size: 4
  - id: segment_count
    type: u2
  - id: unk0a
    size: 6
  - id: segments
    type: segment
    repeat: expr
    repeat-expr: segment_count
types:
  segment:
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: samples
        type: u4
      - id: zero
        type: u4
      - id: name
        size: 0x20
        type: strz
        encoding: ASCII
