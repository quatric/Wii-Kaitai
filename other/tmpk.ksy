meta:
  id: tmpk
  endian: be
  title: Twilight Princess HD / Zelda TMPK archive (.pack)
doc: |
  Twilight Princess HD / Zelda TMPK archive, per lib-tmpk.c. A 16-byte
  header is followed by `num_files` 16-byte directory records. Each record
  contains absolute offsets for a NUL-terminated name and raw member data.
  There is no per-member compression flag or size transform in this layer;
  a `.pack.gz` is a gzip stream around the entire TMPK archive.

  nintoolbox requires 1..100000 members and a complete directory table.
  It uses a generated `file_NNNN.bin` name if a name offset is outside EOF,
  clamps a member crossing EOF to the remaining bytes, and skips members
  whose offset is outside EOF or whose resulting length is zero. The writer
  sorts members, uses only basename components, writes a contiguous string
  table after the directory, and aligns the first and each following data
  position to 32 bytes. The `alignment` field reports that alignment but
  the reader does not use it to locate payloads; it follows entry offsets.
seq:
  - id: magic
    contents: "TMPK"
    doc: Four-byte ASCII archive signature.
  - id: num_files
    type: u4
    doc: Number of directory entries at file offset 0x10.
  - id: alignment
    type: u4
    doc: Intended data alignment. nintoolbox writes 32; its reader treats
      entry offsets as authoritative even if this field differs.
  - id: unknown_0c
    size: 4
    doc: Unknown header word, zero in nintoolbox output and ignored on read.
  - id: entries
    type: entry_t
    repeat: expr
    repeat-expr: num_files
types:
  entry_t:
    seq:
      - id: name_offset
        type: u4
        doc: Absolute offset of this member's NUL-terminated filename.
      - id: file_offset
        type: u4
        doc: Absolute offset of this member's raw data.
      - id: file_size
        type: u4
        doc: Declared member length before reader-side EOF clamping.
      - id: unknown_0c
        type: u4
        doc: Unknown directory word, zero in nintoolbox output.
    instances:
      name:
        pos: name_offset
        type: str
        terminator: 0
        encoding: ASCII
        io: _root._io
        doc: Filename resolved through `name_offset`. Canonical output stores
          only a basename; the reader can also accept embedded path separators.
      body:
        pos: file_offset
        size: file_size
        io: _root._io
        doc: Raw member bytes selected by the directory's absolute range.
