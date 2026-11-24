meta:
  id: kt_wiibgm
  title: Koei Tecmo WiiBGM DSP music (.dsp)
  file-extension: dsp
  endian: be
doc: |
  Koei Tecmo `WiiBGM` DSP music (also inside `.g1l` `G1L_0000` containers of
  type 9: Hyrule Warriors Wii U, Romance of the Three Kingdoms 12). DSP
  coefficients sit at 0x5C (0x60 per channel); ADPCM starts at 0x800 with the
  channels interleaved byte by byte.
seq:
  - id: magic
    contents: ['WiiBGM', 0, 0]
  - id: reserved0
    size: 8
  - id: num_samples
    type: u4
  - id: loop_start
    type: u4
  - id: reserved1
    size: 11
  - id: num_channels
    type: u1
  - id: reserved2
    size: 2
  - id: sample_rate
    type: u2
