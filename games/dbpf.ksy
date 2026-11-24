meta:
  id: dbpf
  title: EA DBPF 2.0 package (.package)
  file-extension: package
  endian: le
doc: |
  EA `DBPF` version 2.0 resource package (MySims, MySims Kingdom, MySims
  Agents). The index is `{u32 flags; one constant u32 for each of the bits 0
  (type), 1 (group), 2 (instance high) that is set; then per entry the
  non-constant fields of {type, group, instance high, instance low}, offset,
  size, memory size and, in the larger indexes, one more u32}`. A member is
  RefPack-compressed when its size (without the 0x80000000 flag) differs from
  its memory size. Type 0x0166038C is a name map `{u32 1, u32 count, count *
  {u64 hash, u32 length, name}}`. Textures (type 0x00B2D882) have a big-endian
  header `{0x14FE0149, version, data size, ..., u16 width, u16 height at 0x1C,
  GX format at 0x20}` and CMPR / RGBA8 pixels at 0x4C followed by mip levels.
seq:
  - id: magic
    contents: DBPF
  - id: major
    type: u4
    doc: 2.
  - id: minor
    type: u4
  - id: reserved0
    size: 0x18
  - id: num_index_entries
    type: u4
  - id: reserved1
    size: 4
  - id: len_index
    type: u4
  - id: reserved2
    size: 0x10
  - id: index_offset
    type: u4
instances:
  index_flags:
    pos: index_offset
    type: u4
