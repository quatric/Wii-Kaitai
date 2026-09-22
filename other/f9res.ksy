meta:
  id: f9res
  file-extension: res
  endian: be
  title: GameCube Resource Archive (res\n)
doc: |
  Flat resource archive, magic `res\n`, ported from nintoolbox's
  `lib-f9res.c` (module comment header "6. GameCube Resource Archive").
  All fields big-endian.

  The header carries two absolute offsets: `header_offset`, added to
  every chunk's stored offset to get its real file position, and
  `chunks_offset`, pointing at the chunk-count table. Each of the
  `chunk_count` 20-byte entries has a 4-byte ASCII tag, an offset
  (relative to `header_offset`) and a size; the remaining 8 bytes are
  unused by the reader.

  The nintoolbox extractor accepts .res and .bin names but identifies this
  format by the magic. It requires a complete table with 1..100000 entries;
  a payload extending beyond EOF is truncated, while empty or out-of-file
  entries produce no extracted file. Extraction names are TAG_NNNN.bin,
  where NNNN is the zero-based table index and non-printable tag bytes become
  underscores. These names are generated, not stored in the archive.

  The nintoolbox writer sorts input entries by name, derives each tag from
  up to four basename bytes preceding the first underscore (default DATA),
  writes both header_offset and chunks_offset as 0x20, and puts 4 in the
  second table word. It aligns the first payload and each following payload
  to 16-byte boundaries; the entry offsets remain relative to 0x20. The
  writer zeros all other header/table reserved bytes and both trailing
  entry words. This is a writer convention, not a general format invariant.
seq:
  - id: magic
    contents: "res\n"
  - id: unknown_04
    size: 4
    doc: Reserved header bytes; zero in nintoolbox-produced archives.
  - id: header_offset
    type: u4
    doc: Base added to each entry's relative payload offset.
  - id: unknown_0c
    size: 16
    doc: Reserved header region; zero in nintoolbox-produced archives.
  - id: chunks_offset
    type: u4
    doc: Absolute file offset of the count word and chunk-entry table.
instances:
  chunk_table:
    pos: chunks_offset
    type: chunk_table_t
types:
  chunk_table_t:
    seq:
      - id: chunk_count
        type: u4
        doc: Number of 20-byte entries; nintoolbox accepts 1 through 100000.
      - id: unknown
        type: u4
        doc: Unused by the extractor; nintoolbox writes 4.
      - id: entries
        type: chunk_entry
        repeat: expr
        repeat-expr: chunk_count
        doc: Consecutive descriptors; payload data may be elsewhere in the file.
  chunk_entry:
    seq:
      - id: tag
        type: str
        size: 4
        encoding: ASCII
        doc: Four raw tag bytes used to synthesize the extracted filename.
      - id: rel_offset
        type: u4
        doc: Payload start relative to the file's header_offset value.
      - id: size
        type: u4
        doc: Declared payload byte count; extractor truncates at EOF.
      - id: unknown
        size: 8
        doc: Two unused 32-bit words, both zero in nintoolbox output.
    instances:
      body:
        io: _root._io
        pos: _root.header_offset + rel_offset
        size: size
        doc: Raw member bytes; this parser does not apply extractor EOF clamping.
