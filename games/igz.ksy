meta:
  id: igz
  title: Alchemy IGZ object file (Madagascar 2 Wii)
  endian: be
doc: |
  Header {"IGZ\x01", u32 version, ... 4 x {u32 offset, size, align, 0} sections
  at 0x10}. Section 0 holds fixup records {u32 tag, ., ., count, length, start}:
  tag 0 type names, 13 type sizes, 5 object offsets, 12/11 pooled memory block
  references. Object offsets and counts are nibble varints (3 bits per nibble,
  low first, bit 3 = continue). Objects {u32 type, u32 refs, fields}.
seq:
  - id: magic
    contents: ["IGZ", 1]
  - id: version
    type: u4
  - id: unk
    size: 8
  - id: sections
    type: section
    repeat: expr
    repeat-expr: 4
types:
  section:
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: align
        type: u4
      - id: zero
        type: u4
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
