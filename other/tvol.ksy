meta:
  id: tvol
  endian: le
  title: Koei Tecmo / Gust Texture Volume Archive (.tvol)
doc: |
  Koei Tecmo / Gust Texture Volume Archive, per lib-tvol.c. Each
  member's name is a NUL-terminated string stored inline at the
  start of its own data.

  There is no magic or separate name table: the file begins with a
  little-endian count followed by count pairs of absolute file offsets and
  byte lengths. Each payload includes its name bytes; extraction writes the
  entire payload, including that prefix, to a .bin file. Consequently the
  parsed body is not just the texture bytes after the name.

  nintoolbox recognizes this format only for .tvol filenames and requires
  1..10000 entries and a complete descriptor table. It skips zero-length
  members and offsets at or past EOF; a member extending beyond EOF is
  truncated on extraction. A name is used only when at least 48 bytes remain
  from its offset: the extractor scans at most the first 47 bytes for a NUL,
  using a nonempty prefix as NAME.bin. Otherwise it uses tex_NNNN.bin, with
  NNNN the zero-based entry index. Those output names are not stored in a
  separate table. This Kaitai instance exposes the inline name but does not
  implement the extractor's bounds checks, fallback naming, or truncation.
seq:
  - id: num_textures
    type: u4
    doc: Number of offset/size descriptors; extractor accepts 1 through 10000.
  - id: entries
    type: entry_t
    repeat: expr
    repeat-expr: num_textures
types:
  entry_t:
    seq:
      - id: offset
        type: u4
        doc: Absolute file offset of the complete member, including its name.
      - id: size
        type: u4
        doc: Declared byte length of the complete member.
    instances:
      name:
        pos: offset
        type: str
        size: 48
        encoding: ASCII
        terminator: 0
        io: _root._io
        if: size != 0
        doc: Inline NUL-terminated name prefix; extractor considers at most 47 bytes.
      body:
        pos: offset
        size: size
        io: _root._io
        doc: Complete raw member, including the inline name prefix.
