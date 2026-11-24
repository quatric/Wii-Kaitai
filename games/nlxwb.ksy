meta:
  id: nlxwb
  title: Next Level Games wave bank bundle (.resbun)
  endian: be
doc: |
  Mario Strikers Charged. Tree of {u32 tag, u32 size} chunks (tag bit 31 =
  container). Chunk 0x03023703 carries the wave table: u32 count (some banks
  put an extra 0 word first), count 0x1c-byte entries {0, rate, 0, 0, end nibble
  address, start nibble address, 0}, then count 0x2e-byte blocks {s16 coef[16],
  gain, initial scale, history 1, history 2, loop scale, loop history 1 / 2}.
  Addresses are nibble offsets into the headerless .nlxwb file.
seq:
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: tag
        type: u4
      - id: size
        type: u4
      - id: body
        size: size
  wave_entry:
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
  dsp_block:
    seq:
      - id: coefs
        type: s2
        repeat: expr
        repeat-expr: 16
      - id: gain
        type: u2
      - id: initial_scale
        type: u2
      - id: hist1
        type: s2
      - id: hist2
        type: s2
      - id: loop_scale
        type: u2
      - id: loop_hist1
        type: s2
      - id: loop_hist2
        type: s2
