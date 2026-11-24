meta:
  id: rbin
  title: Dragon Ball Tenkaichi Daibouken RBIN
  file-extension: rbin
  endian: be
doc: |
  Dragon Ball - Tenkaichi Daibouken `*.RBIN`. `n + 1` ascending offsets from
  0x10 are the section starts; the last one is the file size.
seq:
  - id: num_sections
    type: u4
  - id: zeros
    size: 12
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: num_sections + 1
