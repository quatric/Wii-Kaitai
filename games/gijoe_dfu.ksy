meta:
  id: gijoe_dfu
  title: G.I. Joe Rise of Cobra GamePak (.dfu)
  file-extension: dfu
  endian: be
doc: |
  G.I. Joe - The Rise of Cobra `GamePak*.dfu` (~1 GB). Data offsets are 0x800
  aligned and inside the file.
seq:
  - id: count
    type: u4
  - id: header_words
    type: u4
    repeat: expr
    repeat-expr: 5
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: aux
        type: u4
      - id: name_hash
        type: u4
      - id: offset
        type: u4
      - id: len_data
        type: u4
