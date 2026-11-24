meta:
  id: gcax_bank
  title: Sega gcax sound bank (.dat)
  file-extension: dat
  endian: be
doc: |
  Sega `gcax` sound bank (Sonic and the Secret Rings, Sonic and the Black
  Knight; Wii). `gcaxDTPK` holds a `gcaxTBLD` table at 0x60 and the `gcaxPCMD`
  sample pool. TBLD words from 0x68: section offsets live at word 12.., the
  sample section is word 20 (end = word 21): `{u32 count-1, 0x20, 2,
  checksum}` followed by count+1 `sample_record`s. Sample k's data runs from the
  previous record's end (0x20 for the first) to its own end, DSP-ADPCM mono,
  starting with the record's initial predictor/scale.
seq:
  - id: magic
    contents: gcaxDTPK
  - id: reserved0
    size: 8
  - id: len_table
    type: u4
  - id: reserved1
    size: 8
  - id: pcmd_offset
    type: u4
types:
  sample_record:
    doc: 0x44 bytes; positioned via the TBLD section offsets, not modelled as an instance.
    seq:
      - id: dsp_coefficients
        type: s2
        repeat: expr
        repeat-expr: 16
      - id: gain
        type: u2
      - id: initial_ps
        type: u2
      - id: hist1
        type: u2
      - id: hist2
        type: u2
      - id: loop_ps
        type: u2
      - id: loop_hist1
        type: u2
      - id: loop_hist2
        type: u2
      - id: flags
        type: u2
        doc: 0x0200 DSP-ADPCM, +0x0400 looped.
      - id: sample_rate
        type: u2
      - id: padding
        type: u2
      - id: len_data
        type: u4
      - id: end_offset
        type: u4
        doc: Cumulative, relative to the PCMD tag.
      - id: unknown
        type: u4
        repeat: expr
        repeat-expr: 2
