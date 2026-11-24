meta:
  id: muskrome
  title: Krome Studios music stream (.mus)
  file-extension: mus
  endian: be
doc: |
  Krome Studios `.mus` streams (Star Wars: The Force Unleashed, Wii; also Ty 2 on
  GameCube; layout after vgmstream `mus_krome`). Data size + 0x80 is the file
  size; a DSP coefficient block per channel follows the header.
seq:
  - id: num_samples
    type: u4
  - id: interleave
    type: u4
    doc: 0x8000.
  - id: data_start
    type: u4
    doc: 0x80.
  - id: len_data
    type: u4
  - id: rest
    size-eos: true
