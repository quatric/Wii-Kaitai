meta:
  id: sega_abst
  title: SEGA ABST asset schedule (.asd)
  file-extension: asd
  endian: le
doc: |
  SEGA `ABST` asset schedule (Sakura Wars: So Long, My Love `*.asd`). A
  zero-terminated sorted list of u32 chunk offsets starts at 0x24 (the first is the
  header size). Chunks are `{tag, u32, u32, 0}`: `ASAD` asset descriptors (the
  32-byte name at +0x10 is the asset: evmap, light_ev, fog, glare_ev, GZR_EFEV...)
  and `ASSC` schedule blocks. The meaning of the numeric fields is not known.
seq:
  - id: magic
    contents: ABST
  - id: len_file
    type: u4
  - id: header_size
    type: u4
    doc: 0x30..0x1a0, a multiple of 16.
  - id: zero0
    type: u4
  - id: seven
    type: u4
  - id: constant_0x24
    type: u4
  - id: three
    type: u4
  - id: constant_0x40
    type: u4
  - id: zero1
    type: u4
  - id: chunk_offsets
    type: u4
    repeat: until
    repeat-until: _ == 0
