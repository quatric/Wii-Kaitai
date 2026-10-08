meta:
  id: worms_spt
  title: Worms / Activision SPT audio bank index (.spt, with .spd)
  file-extension: spt
  endian: be
doc: |
  Team17 / Activision audio bank index. `X.spd` holds raw GameCube DSP-ADPCM
  frames and `X.spt` is this big-endian index: a count, `count` 28-byte
  records and `count` 46-byte DSP blocks. Each stream is written as a
  standard `.dsp`.
seq:
  - id: count
    type: u4
  - id: records
    type: record
    repeat: expr
    repeat-expr: count
  - id: dsp_blocks
    type: dsp_block
    repeat: expr
    repeat-expr: count
types:
  record:
    seq:
      - id: zero0
        type: u4
      - id: sample_rate
        type: u4
      - id: zero8
        type: u4
      - id: zero_c
        type: u4
      - id: end_nibble
        type: u4
      - id: start_nibble
        type: u4
      - id: zero_18
        type: u4
  dsp_block:
    seq:
      - id: coefs
        type: s2
        repeat: expr
        repeat-expr: 16
      - id: gain
        type: u2
      - id: initial_ps
        type: u2
      - id: hist1
        type: s2
      - id: hist2
        type: s2
      - id: loop_ps
        type: u2
      - id: loop_hist1
        type: s2
      - id: loop_hist2
        type: s2
