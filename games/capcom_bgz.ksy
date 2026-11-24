meta:
  id: capcom_bgz
  title: Capcom pre-rendered background pack (.bgz)
  file-extension: bgz
  endian: be
doc: |
  Capcom `*.bgz` pre-rendered background pack (Resident Evil Archives: Resident
  Evil, Wii `st*/r*.bgz`). After the header come, per camera angle, small binary
  blocks (float data, `shd.` tables) and one or more JFIF JPEG images. The
  binary block layout is not decoded by nintoolbox, which carves the file into
  JPEG and non-JPEG pieces; only the header is modelled.
instances:
  len_header:
    pos: 0
    type: u4
    doc: 0x20 * number of entries.
  entries:
    pos: 0
    type: entry
    repeat: expr
    repeat-expr: len_header / 0x20
types:
  entry:
    seq:
      - id: len_header
        type: u4
      - id: w1
        type: u4
      - id: w2
        type: u4
      - id: w3
        type: u4
      - id: w4
        type: u4
      - id: one
        type: u4
      - id: zero
        size: 8
