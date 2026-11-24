meta:
  id: pacs
  title: Konami PACS sound pack (.sep)
  file-extension: sep
  endian: be
doc: |
  Konami `PACS` sound pack (`.sep` Mahjong Fight Club, `SND_DATA` packs inside Pro
  Evolution Soccer `.afs` archives). After the header come a chunk offset table
  and tagged chunks (`PHED`, `PRAM`, `TONE`, `SEQ`, `BANK`, `WHED`, ...). The wave
  table is a run of 0x50-byte `WVHD` records; `WDAT` follows with the DSP-ADPCM
  data of all waves back to back.
seq:
  - id: magic
    contents: PACS
  - id: len_file
    type: u4
  - id: count
    type: u2
types:
  wvhd:
    seq:
      - id: tag
        contents: WVHD
      - id: data_offset
        type: u4
      - id: len_data
        type: u4
      - id: sample_rate
        type: u2
      - id: zero0
        type: u2
      - id: num_samples
        type: u4
      - id: start_nibble
        type: u4
      - id: end_nibble
        type: u4
      - id: zero1
        type: u4
      - id: end_plus_1
        type: u4
      - id: dsp_coefficients
        type: s2
        repeat: expr
        repeat-expr: 16
      - id: predictor_scale
        type: u2
      - id: hist1
        type: u2
      - id: hist2
        type: u2
      - id: loop_predictor_scale
        type: u2
      - id: loop_hist1
        type: u2
      - id: loop_hist2
        type: u2
