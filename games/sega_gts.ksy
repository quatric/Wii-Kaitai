meta:
  id: sega_gts
  title: Sega texture set (.gts)
  file-extension: gts
  endian: be
doc: |
  Sega texture set `.gts` (Ghost Squad, Wii). Unused offset slots are
  0xFFFFFFFF. Each entry is `{u32 GVR size, char name[0x3c]}` followed at +0x40
  by a complete GVR texture (`GCIX` / `GVRT`).
seq:
  - id: len_file
    type: u4
  - id: magic
    contents: gts1
  - id: count
    type: u2
  - id: zero
    type: u2
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: len_gvr
        type: u4
      - id: name
        size: 0x3c
        type: strz
        encoding: ASCII
      - id: gvr
        size: len_gvr
