meta:
  id: sonic_gncp
  title: Sonic Team NGIF UI layout (.gncp, Sonic Colors)
  file-extension: gncp
  endian: be
doc: |
  Chunk sizes are little endian, everything else big endian. Data chunk
  ("nCPJ") at 0x20, then NOF0 pointer list {u32 LE size, u32 count, 0, count
  u32 slot offsets relative to 0x20} and NEND. Slots hold offsets relative to 0x20.
seq:
  - id: magic
    contents: NGIF
  - id: size
    type: u4le
    doc: 0x18.
  - id: flags
    type: u4
  - id: data_start
    type: u4
    doc: 0x20.
  - id: data_end
    type: u4
  - id: nof0_offset
    type: u4
  - id: nof0_size
    type: u4
  - id: one
    type: u4
instances:
  data_chunk:
    pos: data_start
    type: chunk
  nof0:
    pos: nof0_offset
    type: nof0
types:
  chunk:
    seq:
      - id: tag
        size: 4
        type: str
        encoding: ASCII
      - id: size
        type: u4le
      - id: body
        size: size
  nof0:
    seq:
      - id: tag
        contents: NOF0
      - id: size
        type: u4le
      - id: count
        type: u4
      - id: zero
        type: u4
      - id: slots
        type: u4
        repeat: expr
        repeat-expr: count
