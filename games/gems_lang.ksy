meta:
  id: gems_lang
  title: Groovin Blocks string table (.lang)
  file-extension: lang
  endian: be
doc: |
  Groovin' Blocks (Wii, Gems engine) `Lang/<lang>/Strings/*.lang`. `count`
  offsets point at `{u32 text offset, u32 string hash}` records (they follow the
  offset table, 8 bytes each); texts are NUL-terminated UTF-16BE.
seq:
  - id: entry_size
    type: u4
    doc: 8.
  - id: count
    type: u4
  - id: record_offsets
    type: u4
    repeat: expr
    repeat-expr: count
