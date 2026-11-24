meta:
  id: glacier_tex
  title: IO Interactive Glacier texture bank (.TEX)
  file-extension: tex
  endian: be
doc: |
  Glacier texture bank (Mini Ninjas, Wii; `.TEX` in the scene `.zip` packs).
  From 0x10, one entry per texture, each on a 16-byte boundary: `{u32 size (from
  the entry start to the end of the last mip), char format[4] twice, u32 id,
  u16 width, u16 height, u32 mip count, u32 0, f32 1.0, u32 0, NUL-terminated
  name (may be empty), then per mip {u32 size, data}}`. A `PALN` entry is
  followed by its palette `{u32 count, count x {A, B, G, R}}`. Entries whose two
  format words differ are id groups `{u32 count, count x u32 id}`. The texture
  area ends at the table offset (runtime offset tables, all zero).
seq:
  - id: table_offset
    type: u4
  - id: end
    type: u4
  - id: zero
    type: u4
  - id: constant
    contents: [0x04, 0x00, 0x00, 0x00]
