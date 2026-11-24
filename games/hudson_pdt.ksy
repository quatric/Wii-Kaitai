meta:
  id: hudson_pdt
  title: Hudson GameCube sound bank (.pdt)
  file-extension: pdt
  endian: be
doc: |
  Mario Party 4, Cubic Lode Runner, Adventure Island. Entries sharing a data
  offset are one sound.
seq:
  - id: one
    type: u2
  - id: entry_count
    type: u2
  - id: two_or_four_a
    type: u2
  - id: pad6
    size: 2
  - id: rate_marker
    type: u4
    doc: 0x7d00.
  - id: two_or_four_b
    type: u4
  - id: entry_pointers_offset
    type: u4
    doc: Always 0x10.
  - id: coef_table_offset
    type: u4
instances:
  entry_pointers:
    pos: entry_pointers_offset
    type: u4
    repeat: expr
    repeat-expr: entry_count
  coef_sets:
    pos: coef_table_offset
    size: 0x20
    repeat: expr
    repeat-expr: 1
    doc: 0x20 bytes per set; set count is the maximum index referenced.
types:
  entry:
    seq:
      - id: flags
        type: u4
        doc: 1 stereo, 2 loop.
      - id: rate
        type: u4
      - id: nibbles
        type: u4
      - id: loop_start
        type: u4
      - id: channel1_offset
        type: u4
      - id: coef_set
        type: u2
      - id: pad
        size: 2
      - id: channel2_offset
        type: u4
