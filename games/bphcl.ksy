meta:
  id: bphcl
  title: Phive cloth (.bphcl) / navigation mesh (.bphnm)
  endian: be
doc: |
  Havok 2025.2 hkai data as a TAG0 tag file; a trailing non-AAMP block of 13
  floats is appended in the YAML output as trailer_f32, and a trailing AAMP block
  carries the cloth parameters (see aamp.ksy).
seq:
  - id: rest
    size-eos: true
