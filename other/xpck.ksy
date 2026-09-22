meta:
  id: xpck
  endian: le
  title: Level-5 3DS/Switch container archive (XPCK/XPC2)
doc: |
  Level-5 container archive (.xc/.xpck), per lib-xpck.c. All table
  section offsets and relative payload offsets are stored in units of
  four bytes; member sizes themselves are byte counts. The fixed header
  is 0x10 bytes, not 0x20: the file-info table may start immediately at
  0x10. Names are consecutive NUL-terminated strings in a separate
  filename table and correspond to file-info records by index.

  nintoolbox accepts XPCK or XPC2 magic in .xc, .xpck, or .bin files. It
  requires the file-info and filename-table start offsets to be inside
  the file, but stops on a truncated descriptor rather than rejecting
  the entire archive. It uses the filename table only if its complete
  declared range fits; an empty/missing name becomes file_NNNN.bin.
  Oversized payloads are truncated to EOF. The 32-bit filename CRC and
  reserved two bytes in each descriptor are ignored by the extractor.

  The writer emits XPCK, sorts entries, strips directory prefixes from
  names, and writes each basename's zlib CRC32 to its descriptor. It
  aligns the filename table length to four bytes, the first payload to
  16 bytes, and each subsequent payload to four bytes. It stores only
  the low 12 bits of the entry count, and the 24-bit size/offset fields
  can truncate larger values; those are writer limitations, not general
  guarantees of an arbitrary archive.
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
    valid:
      any-of: ['"XPCK"', '"XPC2"']
  - id: packed_02
    type: u2
    doc: Low 12 bits are the file count; high 4 bits have unknown meaning.
  - id: file_info_offset_units
    type: u2
    doc: Absolute descriptor-table start divided by four.
  - id: file_table_offset_units
    type: u2
    doc: Absolute filename-table start divided by four.
  - id: data_offset_units
    type: u2
    doc: Absolute payload-region start divided by four.
  - id: unknown_0c
    type: u2
    doc: Reader-ignored header word; zero in writer output.
  - id: filename_table_size_units
    type: u2
    doc: Filename-table byte length divided by four, including its padding.
instances:
  num_files:
    value: packed_02 & 0xfff
  file_info_offset:
    value: file_info_offset_units * 4
  file_table_offset:
    value: file_table_offset_units * 4
  data_offset:
    value: data_offset_units * 4
  filename_table_size:
    value: filename_table_size_units * 4
  entries:
    type: entry_t
    repeat: expr
    repeat-expr: num_files
    pos: file_info_offset
    doc: Twelve-byte file descriptors; nintoolbox may stop early on truncation.
  filename_table:
    pos: file_table_offset
    size: filename_table_size
    type: filename_table_t
    if: filename_table_size > 0 and file_table_offset + filename_table_size <= _io.size
    doc: Sequential names and trailing padding; malformed tables may not have all names.
types:
  filename_table_t:
    seq:
      - id: names
        type: str
        encoding: UTF-8
        terminator: 0
        repeat: expr
        repeat-expr: _root.num_files
        doc: Member names in descriptor order; remaining bytes are padding.
  entry_t:
    seq:
      - id: name_crc32
        type: u4
        doc: zlib CRC32 of basename in writer output; reader ignores it.
      - id: unknown_04
        size: 2
        doc: Reader-ignored bytes; zero in writer output.
      - id: offset_lo
        type: u2
      - id: size_lo
        type: u2
      - id: offset_hi
        type: u1
      - id: size_hi
        type: u1
    instances:
      offset:
        value: (offset_lo | (offset_hi << 16)) * 4 + _root.data_offset
        doc: Absolute payload start after adding the data-region base.
      size:
        value: size_lo | (size_hi << 16)
        doc: Payload byte count, not a count of four-byte units.
      body:
        pos: offset
        size: size
        io: _root._io
        doc: Raw declared payload; this parser does not clamp at EOF.
