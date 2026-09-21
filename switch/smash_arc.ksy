meta:
  id: smash_arc
  endian: le
  title: Super Smash Bros. Ultimate ARC archive (data.arc)
doc: |
  Super Smash Bros. Ultimate top-level ARC container, per
  `smash_arc_header_t` in lib-smash-arc.h. The filesystem, search and
  shared-section tables that the offsets below point to are not
  modeled here.
seq:
  - id: magic
    contents: [0x10, 0x32, 0x54, 0x76, 0x98, 0xef, 0xcd, 0xab]
  - id: stream_section_offset
    type: u8
  - id: file_section_offset
    type: u8
  - id: shared_section_offset
    type: u8
  - id: fs_offset
    type: u8
  - id: search_offset
    type: u8
  - id: padding
    type: u8
