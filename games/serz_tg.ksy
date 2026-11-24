meta:
  id: serz_tg
  title: Ubisoft/Kuju SERZ token stream (.TgWii / .GeoWii)
  file-extension: tgwii
  endian: le
doc: |
  Token stream after the header: 0xff 'C' (+5 bytes), 0xff 'P' {name, u32 id,
  u32 child count}, 0xff 'V' {name, type, value}, 0xff 'B' {u32 length, bytes},
  0xff 'p' {u16}, 0xff 'N'. A name/type/string is 0xffff + u32 length + text
  (added to a string table) or a u16 index into it. Later instances of a class
  are written as {u8 entity, payload}. Context-dependent, so only the header
  and a few primitive types are modelled.
seq:
  - id: magic
    contents: SERZ
  - id: version
    type: u4
  - id: stream
    size-eos: true
types:
  string_ref:
    seq:
      - id: tag
        type: u2
      - id: length
        type: u4
        if: tag == 0xffff
      - id: text
        size: length
        type: str
        encoding: ASCII
        if: tag == 0xffff
