meta:
  id: gfpak
  file-extension: gfpak
  endian: le
  title: Game Freak Pokemon Archive (GFLXPACK)
doc: |
  Little-endian archive format, magic `GFLXPACK`, ported from
  nintoolbox's `lib-gfpak.c` (`ExtractGFPAKArchive`). Used by recent
  Pokemon titles' `.gfpak`/`.pak`/`.bin` payloads.

  `info_offset` points at a flat table of 24-byte entries; each entry's
  `comp` field selects how `data` at `offset` is stored (1 = raw, 2 =
  LZ4/zlib, 3 = another codec per the source comment) and whether
  `comp_size` differs from `uncomp_size`.
seq:
  - id: magic
    contents: "GFLXPACK"
  - id: unknown_08
    type: u8
    doc: Often 0x10.
  - id: file_count
    type: u4
  - id: unknown_14
    type: u4
    doc: Often 2.
  - id: info_offset
    type: u8
  - id: name_hash_table_offset
    type: u8
instances:
  entries:
    pos: info_offset
    type: entry
    repeat: expr
    repeat-expr: file_count
types:
  entry:
    seq:
      - id: unknown_00
        type: u2
      - id: comp
        type: u2
        doc: "1 = uncompressed/raw, 2 = LZ4/zlib, 3 = another codec."
      - id: uncomp_size
        type: u4
      - id: comp_size
        type: u4
      - id: unknown_0c
        type: u4
      - id: offset
        type: u8
    instances:
      body:
        io: _root._io
        pos: offset
        size: comp_size
