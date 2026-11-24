meta:
  id: eatext
  title: EA Montreal text container (.loc / .sub, Boogie SuperStar)
  endian: le
doc: |
  ".loc": chunks "LOCH" (header), "LOCI" {size, count, count {u16 id, u16
  index}} and "LOCL" {size, u32, count u32 offsets relative to LOCL, UTF-16LE
  NUL-terminated strings}. ".sub": "ST00" records {u32 record size, u32 start,
  u32 end, u32 width @+0xc, ... "CC\0\0" and a UTF-16LE caption}.
seq:
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: tag
        size: 4
        type: str
        encoding: ASCII
      - id: size
        type: u4
      - id: body
        size: size - 8
  loci:
    seq:
      - id: count
        type: u4
      - id: pairs
        type: pair
        repeat: expr
        repeat-expr: count
  pair:
    seq:
      - id: id
        type: u2
      - id: index
        type: u2
