meta:
  id: serz_tokens
  title: Ubisoft/Kuju SERZ token stream (.TgWii / .GeoWii)
  file-extension: tgwii
  endian: le
doc: |
  Tokens start with 0xff; 'C' is followed by 5 bytes, 'P' {name, u32 id,
  u32 child count}, 'V' {name, type, value}, 'B' {u32 length, bytes}, 'p'
  {u16}, 'N' nothing; geometry adds 'R' {name, u32} and 'A' {name, type, u8
  count, values}. Names/types/strings are `string_ref`s into a table that grows
  with every new string. After the first definition of a P/V/B class, later
  instances are written compactly as {u8 entity, payload}; the entity table
  and V value widths depend on that state, so value payloads of 'V', 'A' and
  compact tokens are kept as opaque here and need an application-side
  decoder. The header is "SERZ" + u32 version.
seq:
  - id: magic
    contents: SERZ
  - id: version
    type: u4
  - id: tokens
    type: token
    repeat: eos
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
  token:
    seq:
      - id: marker
        contents: [0xff]
      - id: kind
        type: u1
        doc: ASCII 'C','P','V','B','p','N','R','A'.
      - id: body
        type:
          switch-on: kind
          cases:
            0x43: five_bytes
            0x50: p_body
            0x42: b_body
            0x70: u2_body
            0x4e: empty
            _: opaque_rest
  five_bytes:
    seq:
      - id: data
        size: 5
  p_body:
    seq:
      - id: name
        type: string_ref
      - id: id
        type: u4
      - id: child_count
        type: u4
  b_body:
    seq:
      - id: length
        type: u4
      - id: data
        size: length
  u2_body:
    seq:
      - id: value
        type: u2
  empty: {}
  opaque_rest:
    doc: V / R / A / compact tokens need the entity table; the remainder is left opaque.
    seq:
      - id: rest
        size-eos: true
