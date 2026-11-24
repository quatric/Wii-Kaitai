meta:
  id: capcaps
  title: Capcom MT Framework Wii sound pack (CAPS)
  endian: be
doc: |
  Type hash 0x7e33a16c. count 0x20-byte "DSPW" descriptors from 0x20 (+0x08 =
  size of descriptor + wave block, +0x18 channels, +0x1c samples); wave blocks
  (DSP headers + ADPCM per channel) are packed from the wave data offset.
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
  - id: count2
    type: u4
  - id: cue_table
    type: u4
  - id: cue_data
    type: u4
  - id: wave_data_offset
    type: u4
  - id: descriptors
    type: descriptor
    repeat: expr
    repeat-expr: count
types:
  descriptor:
    seq:
      - id: tag
        size: 8
        doc: '"DSPW".'
      - id: size
        type: u4
        doc: Descriptor + wave block.
      - id: unk0c
        size: 12
      - id: channels
        type: u4
      - id: samples
        type: u4
