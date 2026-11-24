meta:
  id: nds_swar
  title: Nintendo DS SDK wave archive (.swar)
  file-extension: swar
  endian: le
doc: |
  Nintendo DS SDK wave archive. Every wave starts with a 0x10-byte header
  `{type 0 PCM8 / 1 PCM16 / 2 IMA, loop, rate u16 at +2, ..., IMA predictor s16
  at +0xC, step index at +0xE}` followed by the sample data (see vgmstream
  `swar.c`).
seq:
  - id: magic
    contents: SWAR
  - id: bom
    size: 4
  - id: len_file
    type: u4
  - id: header_size
    type: u2
  - id: num_blocks
    type: u2
  - id: data_magic
    contents: DATA
  - id: len_data_block
    type: u4
  - id: reserved
    size: 0x20
  - id: num_waves
    type: u4
  - id: wave_offsets
    type: u4
    repeat: expr
    repeat-expr: num_waves
types:
  wave_header:
    seq:
      - id: type
        type: u1
      - id: loop
        type: u1
      - id: sample_rate
        type: u2
      - id: reserved
        size: 8
      - id: ima_predictor
        type: s2
      - id: ima_step_index
        type: u2
