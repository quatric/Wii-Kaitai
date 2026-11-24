meta:
  id: ealoc
  title: EA LOCH/LOCL locale string table (.loc)
  file-extension: loc
  endian: le
doc: |
  "LOCH", u32 0x14, 0, 1, 0x14, then the "LOCL" chunk at 0x14 {"LOCL", u32
  size, u32 0, u32 offset[] at +0xc}. Offsets are relative to the chunk; entry
  0 starts a pointer table that also ends the offset list; entries 1.. point
  at NUL-terminated UTF-16LE strings.
seq:
  - id: magic
    contents: LOCH
  - id: header_size
    type: u4
  - id: zero
    type: u4
  - id: one
    type: u4
  - id: locl_offset
    type: u4
instances:
  locl:
    pos: locl_offset
    type: locl
types:
  locl:
    seq:
      - id: magic
        contents: LOCL
      - id: size
        type: u4
      - id: zero
        type: u4
      - id: body
        size: size - 12
        doc: Offset list (entry 0 marks its end), pointer table, UTF-16LE strings.
