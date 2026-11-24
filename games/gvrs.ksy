meta:
  id: gvrs
  title: Sonic Team GVR texture set (.GVRs)
  file-extension: gvrs
  endian: be
doc: |
  Sonic Team `.GVRs` texture set (Sonic and the Secret Rings `Now/*.GVRs`). With
  `flag` 0, `count` NUL-terminated names follow the offset table; every member
  is a complete GVR texture (`GCIX` / `GBIX` + `GVRT`, whose LE u32 at +0x14 gives
  the payload size).
seq:
  - id: count
    type: u2
  - id: flag
    type: u2
    doc: 1 = no names.
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: count
  - id: names
    type: strz
    encoding: ASCII
    repeat: expr
    repeat-expr: count
    if: flag == 0
