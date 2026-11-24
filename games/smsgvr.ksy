meta:
  id: smsgvr
  title: Bleach Shattered Blade .sms container (SMST)
  file-extension: sms
  endian: be
doc: |
  "SMST", u32 body size, u32 entry count, 0x20-byte header, then tagged entries
  ("GCIX", "NGIF" models, "ANMX" animations, "KAZ", "LPS" lip sync, nested
  "SMST"). Texture packs hold GCIX entries {"GCIX", u32 8, 8 bytes 0, then a
  plain Sega "GVRT" {"GVRT", u32 LE size, ...}}, padded to 16 bytes.
seq:
  - id: magic
    contents: SMST
  - id: body_size
    type: u4
  - id: entry_count
    type: u4
  - id: header_rest
    size: 0x20 - 12
  - id: body
    size-eos: true
types:
  gcix_entry:
    seq:
      - id: magic
        contents: GCIX
      - id: eight
        type: u4
      - id: zero
        size: 8
      - id: gvrt_tag
        contents: GVRT
      - id: gvrt_size
        type: u4le
      - id: gvrt_body
        size: gvrt_size
