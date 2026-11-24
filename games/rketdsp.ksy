meta:
  id: rketdsp
  title: Aqua Panic RKET sound bank
  endian: be
doc: Members are complete DSP-ADPCM files located by scanning for consistent DSP headers (start 2, current 2, end = nibbles - 1).
seq:
  - id: magic
    contents: RKET
  - id: rest
    size-eos: true
