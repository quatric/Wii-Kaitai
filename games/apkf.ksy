meta:
  id: apkf
  title: Shrek Forever After APKF resource package (.apk)
  file-extension: apk
  endian: be
doc: |
  Pool entry (0x18): {tag reversed ("IMG\0", "DATA"), u32 flags, 2 words, u32
  size @+0x10, u32 offset @+0x14 relative to the field}. Groups follow from
  +0x1c: {tag reversed ("TEX", "MAT", "MESH", "SKEL", "FONT"), u32 version, u32
  item words, u32 item table offset (from +0xc after the group start), u32 item
  count, u32 per pool word [n] (byte 3 pool index, low 24 bits alignment)},
  ended by a zero tag. TEX item header (0x40): "GCNT", 3, 0x00400000, u32 data
  size, u16 w, u16 h, u8 GX format, u8 palette format, u8 mipmap count - 1, then
  GX pixels (all mips) + 256/16 entry palette.
seq:
  - id: magic
    contents: APKF
  - id: version
    type: u2le
    doc: 0x0105.
  - id: flags
    type: u4
  - id: minus_one
    type: s4
  - id: pool_count
    type: u4
  - id: pool_table_offset
    type: u4
    doc: Counted from +8; the table starts 0xc more bytes in.
instances:
  pools:
    pos: 8 + pool_table_offset + 0xc
    type: pool
    repeat: expr
    repeat-expr: pool_count
types:
  pool:
    seq:
      - id: tag
        size: 4
      - id: flags
        type: u4
      - id: words
        type: u4
        repeat: expr
        repeat-expr: 2
      - id: size
        type: u4
      - id: offset
        type: u4
        doc: Relative to this field.
