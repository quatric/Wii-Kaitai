meta:
  id: nlg_rlt
  title: Next Level Games texture bank (.rlt)
  file-extension: rlt
  endian: be
doc: |
  Next Level Games texture bank (Mario Strikers Charged, Wii) `.rlt`. Offsets
  are relative to the end of the table; the size's top bits are flags. A texture
  is a 0x20-byte big-endian header `{u32 mip levels, u32 kind (1 RGB5A3, 2 CMPR,
  3 RGBA8), 4 colour-depth bytes at 8, u16 width at 0xE, u16 height at 0x10}`
  followed by GX-tiled levels, largest first. The `.res` / `.dmn` variant is
  described by `nlg_res`.
seq:
  - id: magic
    contents: PTLG
  - id: count
    type: u4
  - id: reserved
    size: 8
  - id: records
    type: record
    repeat: expr
    repeat-expr: count
types:
  record:
    seq:
      - id: name_hash
        type: u4
      - id: offset
        type: u4
      - id: size_and_flags
        type: u4
      - id: zero
        type: u4
