meta:
  id: ndcubepac
  endian: be
  title: Nd Cube Wii U flat container (Mario Party 10 / Animal Crossing amiibo Festival)
doc: |
  Nd Cube Wii U flat file container ("PAC\0"), as read by
  ExtractPACArchive() in lib-nintendo-archives.c. Big-endian
  throughout. Each member's payload is compressed data at `file_start`;
  nintoolbox first tries a normal zlib wrapper and falls back to raw DEFLATE.
  The data is not encrypted. `size` is an advertised output length, not a
  strict validity condition: the extractor keeps actual inflate output when
  the two differ.

  The reader requires at least 0x44 bytes, a non-zero `file_total` no greater
  than 200,000, a complete 0x30-byte-per-file table, and `string_start` inside
  the file. It skips an entry whose compressed range is outside EOF or cannot
  be inflated, deriving an `entry_NNNN.bin` name when the name offset is bad.
seq:
  - id: magic
    contents: "PAC\0"
  - id: header_length
    type: u4
    doc: Producer-declared header length; not read by nintoolbox's extractor.
  - id: reserved1
    type: u4
  - id: overall_file_start
    type: u4
    doc: Observed data-area-related header offset at 0x0c; semantics unknown.
  - id: pac_size
    type: u4
    doc: Producer-declared container size; not enforced by the extractor.
  - id: language_count
    type: u4
    doc: Number of 16-byte language entries at `language_start`.
  - id: unknown1
    type: u4
  - id: unknown2
    type: u4
  - id: file_total
    type: u4
    doc: Number of 0x30-byte file entries. The reader limits this to 200,000.
  - id: reserved2
    size: 0xc
  - id: language_start
    type: u4
    doc: Absolute offset of the language table.
  - id: file_header_start
    type: u4
    doc: Absolute offset of the file-entry table.
  - id: string_start
    type: u4
    doc: Absolute offset of the string region. The extractor only checks this
      header value is inside the file; names use their own absolute offsets.
  - id: overall_file_start2
    type: u4
instances:
  languages:
    type: language_entry
    repeat: expr
    repeat-expr: language_count
    pos: language_start
  entries:
    type: file_entry
    repeat: expr
    repeat-expr: file_total
    pos: file_header_start
types:
  language_entry:
    seq:
      - id: language_name
        type: u4
        doc: Unknown language identifier or string reference.
      - id: unknown
        type: u4
      - id: language_file_count
        type: u4
        doc: Count of files associated with this language entry.
      - id: language_offsets_start
        type: u4
        doc: Absolute offset of that language's file-offset list; not yet
          traversed by this definition.
  file_entry:
    seq:
      - id: filename_start
        type: u4
        doc: Absolute offset of this member's NUL-terminated pathname.
      - id: unknown1
        type: u4
      - id: extension_start
        type: u4
        doc: Observed extension-related offset; semantics unknown.
      - id: unknown2
        type: u4
      - id: file_start
        type: u4
        doc: Absolute offset of compressed member bytes.
      - id: size
        type: u4
        doc: Advertised decompressed size. A mismatch with actual output is
          logged but does not make the entry invalid.
      - id: zsize
        type: u4
        doc: Compressed byte length used to bound the source range.
      - id: zsize2
        type: u4
        doc: Second stored compressed-size word; its relation to `zsize` is
          not established, and the extractor uses `zsize`.
      - id: reserved
        size: 0x10
    instances:
      name:
        io: _root._io
        pos: filename_start
        type: strz
        encoding: ASCII
        doc: Resolved NUL-terminated member pathname.
      compressed_data:
        io: _root._io
        pos: file_start
        size: zsize
        doc: >-
          Exact compressed member range. Consumers must try zlib first and
          then raw DEFLATE; `size` is only an advertised output length.
  strz:
    seq:
      - id: value
        type: str
        terminator: 0
        encoding: ASCII
