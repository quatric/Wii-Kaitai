meta:
  id: beetex
  title: Bee Movie Game .Wiitex texture
  file-extension: wiitex
  endian: be
doc: |
  Beenox/Activision (DreamWorks Bee Movie Game, Wii) `*.Wiitex`. A GX CMPR mip
  chain starts at 0x50 (every level at least one 32-byte 8x8 tile). The
  dimensions are not stored in an identified field.
seq:
  - id: version
    type: u4
    doc: 2.
  - id: len_rest
    type: u4
    doc: File size - 0x10.
  - id: constant_0x10
    type: u4
  - id: eight
    type: u4
  - id: reserved
    size: 0x20
  - id: source_name
    size: 0x20
    type: strz
    encoding: ASCII
    doc: E.g. `de_strapA.tga`.
  - id: cmpr_mips
    size-eos: true
