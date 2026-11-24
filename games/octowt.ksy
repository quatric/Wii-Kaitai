meta:
  id: octowt
  title: Octomania wavetable (.wt + .pcm)
  file-extension: wt
  endian: be
doc: |
  Kidz Sports / London Taxi / Battle Rage (gm16pcm.wt, the console form of the
  Roland GM16.DLS bank). Six u32 section offsets {0x18, ..., end of file}; the
  last section holds one 16-byte record per sample {u32 rate (low 16 bits, high
  bits flags), u32 start (samples), u32 length (samples), u32 0} into the
  companion .pcm (BE s16 mono). ADPCM variants have starts in nibbles and 46-byte
  coefficient trailers.
seq:
  - id: section_offsets
    type: u4
    repeat: expr
    repeat-expr: 6
types:
  sample:
    seq:
      - id: rate_flags
        type: u4
      - id: start
        type: u4
      - id: length
        type: u4
      - id: zero
        type: u4
