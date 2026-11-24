meta:
  id: mee
  title: Super Fruit Fall .mee localisation table
  file-extension: mee
  endian: le
doc: |
  Either {u32 count, u32 key bytes, u32 text bytes} (12-byte head) or {u32 0,
  u32 count, u32 key bytes, u32 0, u32 text bytes, u32 0} (24-byte head), then
  `count` NUL-terminated identifiers and `count` NUL-terminated Latin-1 texts.
  The "MEEX" code image (code.mee) is not decoded.
seq:
  - id: first
    type: u4
  - id: rest
    size-eos: true
