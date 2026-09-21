meta:
  id: vcra
  endian: le
  title: Bandai Namco Museum Remix archive (VCRA)
doc: |
  Bandai Namco Museum Remix archive, per lib-vcra.c. Two entry
  layouts exist, selected by whether the word at file offset 0x0C
  is non-zero: a 44-byte entry carrying a CRC, or a 64-byte
  CRC-less entry whose table starts at 0x40 (the layout this
  definition's writer always emits, and the one modeled here).
seq:
  - id: magic
    contents: "VCRA"
  - id: num_entries
    type: u4
  - id: total_size
    type: u4
  - id: unknown_0c
    type: u4
    doc: Non-zero selects the alternate 44-byte, CRC-bearing entry layout.
  - id: unknown_10
    size: 0x40 - 0x10
  - id: entries
    type: entry_t
    repeat: expr
    repeat-expr: num_entries
types:
  entry_t:
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: unknown_08
        size: 64 - 8
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
