meta:
  id: capcom_caps
  title: Capcom MT Framework Wii sound pack (CAPS)
  endian: be
doc: |
  Capcom MT Framework Wii sound pack (type hash 0x7E33A16C). `DSPW`
  descriptors are followed by wave blocks (DSP headers + ADPCM per channel)
  packed back to back from `wave_data_offset`.
seq:
  - id: magic
    contents: CAPS
  - id: version
    type: u4
    doc: 11.
  - id: count
    type: u4
  - id: one
    type: u4
  - id: count_again
    type: u4
  - id: cue_table_offset
    type: u4
  - id: cue_data_offset
    type: u4
  - id: wave_data_offset
    type: u4
  - id: descriptors
    type: dspw
    repeat: expr
    repeat-expr: count
types:
  dspw:
    seq:
      - id: magic
        contents: DSPW
      - id: reserved0
        size: 4
      - id: len_descriptor_and_wave
        type: u4
      - id: reserved1
        size: 12
      - id: num_channels
        type: u4
      - id: num_samples
        type: u4
