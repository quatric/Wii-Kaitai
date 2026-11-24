meta:
  id: sptbank
  title: Rockstar Table Tennis .spt table (+ .spd sample data)
  file-extension: spt
  endian: be
doc: |
  {u32 count} + count * 28-byte records {u32 0, rate, 0, 0, end nibble address,
  start nibble address (2 = first frame), 0} + count * 46-byte DSP-ADPCM
  parameter blocks {s16 coef[16], gain, ps, yn1, yn2, loop_ps, loop_yn1,
  loop_yn2}. The sibling .spd holds the concatenated ADPCM frames; the data of a
  record starts at byte (start - 2) / 2.
seq:
  - id: count
    type: u4
  - id: records
    type: record
    repeat: expr
    repeat-expr: count
  - id: blocks
    type: block
    repeat: expr
    repeat-expr: count
types:
  record:
    seq:
      - id: zero0
        type: u4
      - id: rate
        type: u4
      - id: zero1
        type: u4
      - id: zero2
        type: u4
      - id: end_nibble
        type: u4
      - id: start_nibble
        type: u4
      - id: zero3
        type: u4
  block:
    seq:
      - id: coefs
        type: s2
        repeat: expr
        repeat-expr: 16
      - id: gain
        type: u2
      - id: ps
        type: u2
      - id: yn1
        type: s2
      - id: yn2
        type: s2
      - id: loop_ps
        type: u2
      - id: loop_yn1
        type: s2
      - id: loop_yn2
        type: s2
