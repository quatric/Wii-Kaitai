meta:
  id: lyse
  title: Ubisoft Lyn sound engine LySE wrapper
  endian: le
doc: A short header {"LySE", u32 ...} followed by a standard RIFF/WAVE file.
seq:
  - id: magic
    contents: LySE
  - id: header_rest
    size: 12
  - id: riff
    size-eos: true
