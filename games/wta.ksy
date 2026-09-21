meta:
  id: wta
  endian: be
  title: PlatinumGames WT Archive (.wta)
doc: |
  PlatinumGames WT Archive texture bundle, per lib-wta.c. Endianness
  and detail differ by title; this definition covers the "WTA "
  magic form with separate position/size tables. The unrelated Wii U
  big-endian `\0BTW` form (Star Fox Zero) is not modeled here.

  nintoolbox selects big-endian only when the big-endian version is in
  1..0xffff and its little-endian interpretation is larger than 0xffff;
  otherwise the fields and tables are little-endian. It accepts 1..100000
  members. When both table offsets are at least 0x20 and contain every u32,
  each index supplies a data position and stored size. Otherwise it falls
  back to 32-byte descriptors beginning at 0x20. A member whose stored and
  advertised lengths differ and begins with 0x78 is offered to zlib; failure
  leaves the stored bytes intact.
seq:
  - id: magic
    contents: "WTA "
  - id: version
    type: u4
    doc: Version word. Its big-/little-endian plausibility determines how the
      reader interprets the rest of this WTA form.
  - id: num_files
    type: u4
    doc: Texture/member count; the extractor rejects zero and values above
      100000.
  - id: offset_pos_table
    type: u4
    doc: Offset of per-member data positions when the separate-table form is
      valid; otherwise the reader uses fallback descriptors.
  - id: offset_size_table
    type: u4
    doc: Offset of per-member stored-size values in the separate-table form.
  - id: unknown_14
    size: 0x20 - 0x14
instances:
  positions:
    type: u4
    repeat: expr
    repeat-expr: num_files
    pos: offset_pos_table
    doc: Per-member absolute payload positions for the separate-table form.
  compressed_sizes:
    type: u4
    repeat: expr
    repeat-expr: num_files
    pos: offset_size_table
    doc: Per-member stored lengths. In this form nintoolbox has no separate
      advertised uncompressed size, so it writes the bytes unchanged.
