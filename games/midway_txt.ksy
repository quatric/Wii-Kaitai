meta:
  id: midway_txt
  title: Midway text table (TNA Impact! .txt)
  file-extension: txt
  endian: be
doc: Latin-1 strings (Japanese tables use another code page). The first offset equals 0x10 + 4 * count.
seq:
  - id: zero0
    type: u4
  - id: flags
    type: u4
  - id: zero1
    type: u4
  - id: count
    type: u4
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: count
    doc: Absolute offsets to NUL-terminated strings.
