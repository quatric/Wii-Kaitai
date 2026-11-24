meta:
  id: wsbl
  title: 49Games WSBL sound bank
  endian: be
doc: |
  ADPCM data (`data_size` bytes) sits at the end of the file. Stereo sounds
  hold channel 0 then channel 1 as two halves (second coefficient set at +0x30).
seq:
  - id: magic
    contents: WSBL
  - id: version
    type: u4
  - id: count
    type: u4
  - id: data_size
    type: u4
  - id: pad
    size: 4
  - id: records
    type: record
    repeat: expr
    repeat-expr: count
types:
  record:
    seq:
      - id: unk0
        size: 8
      - id: channels
        type: u4
      - id: rate
        type: u4
      - id: one_float
        type: f4
      - id: data_offset
        type: u4
      - id: samples
        type: u4
      - id: unk1c
        size: 0x14
      - id: second_set_head
        size: 4
        doc: Stereo second coefficient set starts here (+0x30), overlapping `coefs`.
      - id: coefs
        type: s2
        repeat: expr
        repeat-expr: 16
      - id: tail
        size: 0x8c - 0x54
