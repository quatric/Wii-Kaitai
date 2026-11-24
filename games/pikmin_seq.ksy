meta:
  id: pikmin_seq
  title: Pikmin 1 SndData/Seqs/pikiseq.arc
  file-extension: arc
doc: |
  17 JAudio ".jam" sequences back to back with no header (the table lives in the
  game's pikiseq.hed, embedded in the DOL). Offsets are the decompilation's table
  adjusted for the USA retail file (220,992 bytes); each sequence starts with the
  "opentrack" (0xC1) preamble and the last ends at EOF.
seq:
  - id: sequences
    size-eos: true
