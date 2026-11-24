meta:
  id: kdsp
  title: Kuju KDSP voice file (.ksp)
  file-extension: ksp
  endian: be
doc: |
  Kuju `KDSP` voice file (Rebel Raiders: Operation Nighthawk subtitle voices).
  16-bit big-endian mono PCM to the end of the file.
seq:
  - id: magic
    contents: KDSP
  - id: words
    type: u4
    repeat: expr
    repeat-expr: 4
    doc: Sizes and the sample rate (last word).
  - id: padding
    size: 0x1c
    doc: 0xCD.
  - id: pcm16
    size-eos: true
