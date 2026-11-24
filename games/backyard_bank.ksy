meta:
  id: backyard_bank
  title: Backyard Sports sound bank (.bank)
  file-extension: bank
  endian: be
doc: |
  Backyard Sports (Wii) `.bank` sound bank. Every member is a complete Nintendo
  DSP-ADPCM file (0x60-byte header + data) at its offset.
seq:
  - id: last_index
    type: u4
  - id: header_size
    type: u4
    doc: 0x20.
  - id: sample_rate
    type: u4
  - id: one
    type: u4
  - id: num_entries
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: offset
        type: u4
      - id: len_data
        type: u4
    instances:
      data:
        pos: offset
        io: _root._io
        size: len_data
