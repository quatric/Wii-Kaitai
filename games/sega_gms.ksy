meta:
  id: sega_gms
  title: Sega motion pack (.gms)
  file-extension: gms
  endian: be
doc: |
  Sega `*.gms` motion pack (Ghost Squad `motion/*.gms`). The first member starts
  right after the table; members run back to back and the last ends at the end
  of the file. Members are NGIF/NGMO motion data.
seq:
  - id: count
    type: u4
  - id: member_offsets
    type: u4
    repeat: expr
    repeat-expr: count
