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
seq:
  - id: magic
    contents: "res\n"
  - id: unknown_04
    size: 4
  - id: header_offset
    type: u4
  - id: unknown_0c
    size: 16
  - id: chunks_offset
    type: u4
instances:
  chunk_table:
    pos: chunks_offset
    type: chunk_table_t
types:
  chunk_table_t:
    seq:
      - id: chunk_count
        type: u4
      - id: unknown
        type: u4
      - id: entries
        type: chunk_entry
        repeat: expr
        repeat-expr: chunk_count
  chunk_entry:
    seq:
      - id: tag
        type: str
        size: 4
        encoding: ASCII
      - id: rel_offset
        type: u4
      - id: size
        type: u4
      - id: unknown
        size: 8
    instances:
      body:
        io: _root._io
        pos: _root.header_offset + rel_offset
        size: size
