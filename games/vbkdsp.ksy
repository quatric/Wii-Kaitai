meta:
  id: vbkdsp
  title: Destroy All Humans Big Willy Unleashed .vbi index
  file-extension: vbi
  endian: be
doc: |
  Index for the matching .vbk bank. Each sound there is {u32 2, u32 nibbles,
  u32 nibbles, u32 2, DSP coefficients, gain, ps, history...} with DSP-ADPCM
  frames from +0x40.
seq:
  - id: entries
    type: entry
    repeat: eos
types:
  entry:
    seq:
      - id: offset
        type: u4
      - id: sample_rate
        type: f4
      - id: volume
        type: f4
      - id: one
        type: u4
