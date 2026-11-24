meta:
  id: eashpg
  title: EA SHPG shape/texture archive (.gsh)
  file-extension: gsh
doc: |
  Usually RefPack-compressed ("10 fb" + 24-bit size) on disc.
  Record chain: {u8 code, u24 next offset (record size), ...}; code 0x10+N is a
  GX texture of format N (u16 width, u16 height at +4, pixels at +0x10); a
  following 0x3N record is the palette (N = GX palette format) for C4/C8.
seq:
  - id: magic
    contents: SHPG
  - id: size
    type: u4le
  - id: count
    type: u4be
  - id: directory_tag
    size: 4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: name
        size: 4
      - id: offset
        type: u4be
