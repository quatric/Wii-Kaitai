meta:
  id: capcomtres
  title: Capcom TRES text resource (.txtres)
  file-extension: txtres
  endian: be
doc: Resident Evil Umbrella / Darkside Chronicles. Strings are NUL-terminated UTF-8, consecutive for multi-string records.
seq:
  - id: magic
    contents: TRES
  - id: version
    type: u4
  - id: count
    type: u4
  - id: pad
    size: 4
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: count
types:
  record:
    seq:
      - id: id
        type: u4
      - id: label_offset
        type: u4
        doc: 0 = none.
      - id: string_count
        type: u4
      - id: first_text_offset
        type: u4
      - id: zero
        type: u4
