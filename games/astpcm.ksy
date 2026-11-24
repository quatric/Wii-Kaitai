meta:
  id: astpcm
  title: Squeeballs Party PCM stream (.ast)
  file-extension: ast
  endian: be
doc: |
  Squeeballs Party (Wii) `Music/*.ast`: interleaved PCM16 samples after a 0x68
  byte header (not the Nintendo `STRM` AST, see `nintendo_ast`). File size is
  `0x68 + frames * channels * 2`.
seq:
  - id: num_frames
    type: u4
  - id: num_channels
    type: u2
  - id: sample_rate
    type: u2
  - id: two
    type: u2
  - id: zero
    type: u2
  - id: padding
    size: 0x58
  - id: pcm16
    size-eos: true
