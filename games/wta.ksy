meta:
  id: wta
  endian: be
  title: PlatinumGames WT Archive (.wta)
doc: |
  PlatinumGames WT Archive texture bundle, per lib-wta.c. Endianness
  and detail differ by title; this definition covers the "WTA "
  magic form with separate position/size tables. The unrelated Wii U
  big-endian `\0BTW` form (Star Fox Zero) is not modeled here.
seq:
  - id: magic
    contents: "WTA "
  - id: version
    type: u4
  - id: num_files
    type: u4
  - id: offset_pos_table
    type: u4
  - id: offset_size_table
    type: u4
  - id: unknown_14
    size: 0x20 - 0x14
instances:
  positions:
    type: u4
    repeat: expr
    repeat-expr: num_files
    pos: offset_pos_table
  compressed_sizes:
    type: u4
    repeat: expr
    repeat-expr: num_files
    pos: offset_size_table
