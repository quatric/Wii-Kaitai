meta:
  id: rcchr
  title: Power Punch fighter record (.chr)
  file-extension: chr
  endian: le
doc: |
  Power Punch (Wii) `charaNNNNN.chr` / `Dummy.chr` fighter record, always 32 bytes.
  The five floats look like per-fighter body measurements (~175 / ~89 / 89 / ~175 /
  89.34); `Dummy.chr` has all five = -1. Meanings are unconfirmed.
seq:
  - id: magic
    contents: ['RC ', 2]
  - id: one
    type: u4
  - id: minus_one
    type: s2
  - id: zero
    type: u2
  - id: measurements
    type: f4
    repeat: expr
    repeat-expr: 5
