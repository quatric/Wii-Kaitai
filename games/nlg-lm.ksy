meta:
  id: nlg_lm
  endian: be
  title: Next Level Games LM2/LM3 dictionary archive (.dict)
doc: |
  Next Level Games "LM2"/"LM3" .dict archive header (Luigi's Mansion:
  Dark Moon / Luigi's Mansion 3), as read by ScanLM2Dict()/
  ScanLM3Dict() in lib-nlg-lm.c (ported from KillzXGaming's
  NextLevelLibrary). Identified structurally by the BE/LE identifier
  0x5824F3A9 rather than a text magic; LM2 and LM3 share that
  identifier but differ in the fixed header shape that follows it
  (LM2 stores its file count as a full u32 and keeps a per-file
  Unknowns byte table before the block table; LM3 packs file/chunk/
  string counts as single bytes). This definition covers the LM3
  shape; LM2's differs only in the fields noted below.

  A block entry (`nlg_block_t`) is a flat, format-shared 16-byte
  record: little-endian offset/decomp_size/comp_size/flags, found
  right after the chunk table (LM3) or after chunk table + a
  per-file Unknowns byte array (LM2).
seq:
  - id: identifier
    type: u4
    doc: 0x5824F3A9 (checked in either endianness by the reference reader).
  - id: unknown1
    type: u2
  - id: is_compressed
    type: u1
    doc: 1 = block payloads are zlib/zstd-compressed.
  - id: unknown2
    type: u1
  - id: unknown3
    size: 4
    doc: Bytes 8..11; unused by the reference reader.
  - id: n_files
    type: u1
    doc: |
      LM3 only; LM2 instead stores this as a little-endian u4 at the
      same absolute offset (see ScanLM2Dict).
  - id: n_chunks
    type: u1
  - id: n_strings
    type: u1
  - id: reserved
    size: 1
  - id: chunk_table
    type: chunk_info
    repeat: expr
    repeat-expr: n_chunks
  - id: blocks
    type: block_entry
    repeat: expr
    repeat-expr: n_files
types:
  chunk_info:
    doc: LM3's 24-byte ChunkInfo record (LM2's is 12 bytes; not modeled here).
    seq:
      - id: data
        size: 24
  block_entry:
    doc: |
      Shared 16-byte block-table record (nlg_block_t): little-endian
      fields regardless of the archive's own endianness.
    seq:
      - id: offset
        type: u4le
      - id: decomp_size
        type: u4le
      - id: comp_size
        type: u4le
      - id: flags
        type: u4le
    instances:
      source_index:
        value: (flags >> 16) & 0xff
      flags_lo:
        value: flags & 0xff
      flags_hi:
        value: (flags >> 24) & 0xff
  nlg_chunk_entry:
    doc: |
      One 12-byte parsed chunk-table entry (nlg_chunk_t / ScanNLGChunks),
      used by the typed model/texture/skeleton/animation extraction on
      top of a decoded block, not by the .dict header itself.
    seq:
      - id: type
        type: u2le
      - id: flags
        type: u2le
      - id: size
        type: u4le
        doc: Child count when this entry is a parent, else leaf data size.
      - id: offset
        type: u4le
        doc: Child index when a parent, else leaf data offset.
    instances:
      is_file:
        value: type == 0x1301
