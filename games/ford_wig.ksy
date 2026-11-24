meta:
  id: ford_wig
  title: Ford Racing Off Road graphics.wig (inflated)
  file-extension: wig
  endian: le
doc: |
  Inflated body of Ford Racing - Off Road `graphics.wig`. On disk the file is
  `le32 inflated size` and a zlib stream; this describes what the zlib stream
  inflates to. Images are at `0x10 + 16 * count + offset`, each with its own
  0x40-byte header (`le32 0, 1, width, height, ...`).
seq:
  - id: count
    type: u4
  - id: zeros
    size: 12
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: offset
        type: u4
      - id: name
        size: 12
        type: strz
        encoding: ASCII
