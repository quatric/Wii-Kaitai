meta:
  id: climax_arc
  title: "Climax data.arc / igc.arc (Silent Hill: Shattered Memories)"
  file-extension: arc
  endian: le
doc: |
  Climax `data.arc` / `igc.arc` (Silent Hill: Shattered Memories, Wii; not the
  Nintendo U8 `.arc`). The first member sits at `data_offset` (0x8000) and every
  offset is 0x800 aligned. A member is a zlib stream when its unpacked size is
  non-zero and it starts with 0x78, otherwise stored as is. Names are hashes.
  The archives are over a gigabyte, so no `data` instance is declared.
seq:
  - id: tag
    type: u4
  - id: num_entries
    type: u4
  - id: data_offset
    type: u4
    doc: 0x8000.
  - id: zero
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: name_hash
        type: u4
      - id: offset
        type: u4
      - id: len_stored
        type: u4
      - id: len_unpacked
        type: u4
