meta:
  id: wta
  endian: le
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
  - id: version_le
    type: u4
    doc: Little-endian view of the version word at 0x04.
  - id: num_files_le
    type: u4
    doc: Little-endian view of the member count at 0x08.
  - id: offset_pos_table_le
    type: u4
    doc: Little-endian view of the position-table offset at 0x0c.
  - id: offset_size_table_le
    type: u4
    doc: Little-endian view of the size-table offset at 0x10.
  - id: unknown_14
    size: 0x20 - 0x14
    doc: Remaining five header words. Their table/flag semantics vary by title.
instances:
  version_be:
    pos: 4
    type: u4be
    doc: Big-endian view of the version word.
  num_files_be:
    pos: 8
    type: u4be
    doc: Big-endian view of the member count.
  offset_pos_table_be:
    pos: 12
    type: u4be
    doc: Big-endian view of the data-position table offset.
  offset_size_table_be:
    pos: 16
    type: u4be
    doc: Big-endian view of the stored-size table offset.
  is_big_endian:
    value: version_be > 0 and version_be <= 0xffff and version_le > 0xffff
    doc: >-
      nintoolbox's exact endian discriminator: only a plausible small
      big-endian version whose little-endian reading is implausibly large
      selects the big-endian interpretation.
  version:
    value: "is_big_endian ? version_be : version_le"
    doc: Version selected by the reader's endian discriminator.
  num_files:
    value: "is_big_endian ? num_files_be : num_files_le"
    doc: >-
      Selected member count; valid archives have 1..100000 members.
  offset_pos_table:
    value: "is_big_endian ? offset_pos_table_be : offset_pos_table_le"
    doc: Selected data-position table offset.
  offset_size_table:
    value: "is_big_endian ? offset_size_table_be : offset_size_table_le"
    doc: Selected stored-size table offset.
  uses_separate_tables:
    value: offset_pos_table >= 0x20 and offset_size_table >= 0x20
    doc: >-
      True when header offsets select the ordinary pair of u32 tables.  A
      reader must also verify each complete table lies in the file; otherwise
      it falls back to 32-byte descriptors at offset 0x20.
  positions_le:
    type: u4
    repeat: expr
    repeat-expr: num_files
    pos: offset_pos_table
    if: not is_big_endian and uses_separate_tables
    doc: Little-endian per-member absolute payload positions.
  compressed_sizes_le:
    type: u4
    repeat: expr
    repeat-expr: num_files
    pos: offset_size_table
    if: not is_big_endian and uses_separate_tables
    doc: Little-endian per-member stored lengths.
  positions_be:
    type: u4be
    repeat: expr
    repeat-expr: num_files
    pos: offset_pos_table
    if: is_big_endian and uses_separate_tables
    doc: Big-endian per-member absolute payload positions.
  compressed_sizes_be:
    type: u4be
    repeat: expr
    repeat-expr: num_files
    pos: offset_size_table
    if: is_big_endian and uses_separate_tables
    doc: Big-endian per-member stored lengths.
  fallback_descriptors_le:
    pos: 0x20
    type: fallback_descriptor
    repeat: expr
    repeat-expr: num_files
    if: not is_big_endian and not uses_separate_tables
    doc: >-
      Little-endian fallback descriptors.  Their payloads begin together at
      0x20 + num_files * 0x20; the implementation has no per-descriptor data
      position in this fallback form.
  fallback_descriptors_be:
    pos: 0x20
    type: fallback_descriptor_be
    repeat: expr
    repeat-expr: num_files
    if: is_big_endian and not uses_separate_tables
    doc: Big-endian fallback descriptors.
types:
  fallback_descriptor:
    seq:
      - id: unknown_00
        size: 12
        doc: Unknown descriptor prefix.
      - id: advertised_size
        type: u4
        doc: Advertised uncompressed byte length.
      - id: stored_size
        type: u4
        doc: Stored byte length; it bounds the source and controls zlib attempt.
      - id: unknown_14
        size: 12
        doc: Unknown descriptor suffix.
  fallback_descriptor_be:
    seq:
      - id: unknown_00
        size: 12
      - id: advertised_size
        type: u4be
      - id: stored_size
        type: u4be
      - id: unknown_14
        size: 12
