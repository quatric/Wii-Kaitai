meta:
  id: dhgc
  title: Twinkle Queen image archive (.cg)
  file-extension: cg
  endian: be
doc: |
  Twinkle Queen (Wii) `Battle/*.cg` image archive. The 0x20-byte entries start at
  0x18 and the directory runs up to the first offset; member data lies at
  `offset + 8`. Members are TPL images.
seq:
  - id: magic
    contents: DHGC
  - id: len_payload
    type: u4
  - id: flags
    size: 4
  - id: type
    size: 12
    type: strz
    encoding: ASCII
    doc: '`tpl`.'
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: (first_offset - 0x18) / 0x20
instances:
  first_offset:
    pos: 0x24
    type: u4
types:
  entry:
    seq:
      - id: zero0
        type: u4
      - id: zero1
        type: u4
      - id: len_data
        type: u4
      - id: offset
        type: u4
      - id: name
        size: 16
        type: strz
        encoding: ASCII
