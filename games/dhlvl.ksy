meta:
  id: dhlvl
  title: G.I. Joe Rise of Cobra level pack (.lvl_NNN)
  endian: be
doc: |
  G.I. Joe: The Rise of Cobra `*.lvl_NNN` level pack. Entries with size 0 are
  placeholders.
seq:
  - id: data_start
    type: u4
  - id: num_entries
    type: u4
  - id: reserved
    size: 0x78
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: name_hash
        type: u4
      - id: offset
        type: u4
      - id: len_data
        type: u4
      - id: type
        type: u4
