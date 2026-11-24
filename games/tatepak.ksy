meta:
  id: tatepak
  title: Titeuf TATE PAK
  file-extension: pak
  endian: le
doc: PAKz wraps this in "zst1" + 8 bytes + a zlib stream.
seq:
  - id: magic
    contents: TATE
  - id: total_size
    type: u4
  - id: item_count
    type: u4
  - id: zero
    type: u4
  - id: name
    size: 0xf0
    type: strz
    encoding: ASCII
  - id: items
    type: item
    repeat: expr
    repeat-expr: item_count
types:
  item:
    seq:
      - id: magic
        contents: item
      - id: size
        type: u4
      - id: index
        type: u4
      - id: zero
        type: u4
      - id: name
        size: 0x70
        type: strz
        encoding: ASCII
      - id: data
        size: size
      - id: align
        size: (-(size + 0x80)) % 0x80
