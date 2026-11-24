meta:
  id: musdsp
  title: Build-A-Bear engine speech/music chunk (.mus)
  file-extension: mus
  endian: be
doc: |
  `.mus` speech / music chunks of the Build-A-Bear / Alien Syndrome / Despicable
  Me engine (Wii). DSP-ADPCM frames follow (file size - 0x30). There is no
  sample count in the header.
seq:
  - id: magic
    contents: [0xef, 0xef, 0xef, 0xef]
  - id: dsp_coefficients
    type: s2
    repeat: expr
    repeat-expr: 16
  - id: gain
    type: u2
    doc: 0.
  - id: initial_ps
    type: u2
  - id: hist1
    type: u2
  - id: hist2
    type: u2
  - id: len_data
    type: u4
  - id: adpcm_frames
    size-eos: true
