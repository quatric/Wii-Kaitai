meta:
  id: sir0
  endian: le
  title: Pokemon Mystery Dungeon SIR0 resource container
doc: |
  Pokemon Mystery Dungeon "SIR0" resource container, per lib-sir0.c.
  Three segments: primary data (0x10 up to sub_header_offset),
  subheader (up to pointer_offsets_offset), and the pointer-offset
  table to the end of the file; internal pointer-relocation content
  is not modeled.
seq:
  - id: magic
    contents: "SIR0"
  - id: sub_header_offset
    type: u4
  - id: pointer_offsets_offset
    type: u4
  - id: unknown_0c
    type: u4
    doc: Usually 0.
instances:
  data_segment:
    pos: 0x10
    size: sub_header_offset - 0x10
    if: sub_header_offset >= 0x10
  sub_header_segment:
    pos: sub_header_offset
    size: pointer_offsets_offset - sub_header_offset
    if: pointer_offsets_offset >= sub_header_offset
  pointer_offsets_segment:
    pos: pointer_offsets_offset
    size-eos: true
