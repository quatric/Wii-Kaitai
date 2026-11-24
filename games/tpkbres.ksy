meta:
  id: tpkbres
  title: Kidz Bop Dance Party .tpk texture pack
  file-extension: tpk
  endian: be
doc: |
  Zero-terminated ascending list of offsets to BRRES files; each BRRES length
  is at +8 inside the member.
seq:
  - id: zero
    type: u4
  - id: table_offset
    type: u4
    doc: 0x10.
  - id: pad
    size: 8
instances:
  offsets:
    pos: table_offset
    type: u4
    repeat: until
    repeat-until: _ == 0
