meta:
  id: arcv
  file-extension: arc
  endian: le
  title: Namco / Tose ARCV archive
doc: |
  A flat, unnamed-member archive used by Namco/Tose Wii titles; shares
  the .arc extension with several unrelated formats (RARC, Brawl PAC,
  etc.), so callers must check the `ARCV` magic before trusting this.
  Members carry no on-disk name -- only their ordinal position, which
  extractors surface as `file_%04u<ext>` -- and a per-member CRC32.

  The extractor accepts this only for .arc filenames with ARCV magic. It
  requires a nonzero entry count, a complete 12-byte-per-entry descriptor
  table, len_file equal to the actual file length, and every payload to
  start after the table and end within the file. It does not verify the
  stored CRC32 while extracting. Output extensions are inferred from the
  first four payload bytes: bres -> .brres, RSEQ -> .rseq, RSTM -> .rstm,
  RWAV -> .rwav, RARC -> .rarc, and ARC plus NUL -> .pac. All other
  payloads use .bin. These filenames/extensions are extractor inventions.

  The nintoolbox writer reconstructs descriptor order from contiguous
  file_0000, file_0001, ... names, ignores derived side-products, computes
  CRC32 with zlib, and writes payloads contiguously immediately after the
  table. Descriptor order is semantically important because filenames are
  not present in the archive. No payload alignment is imposed by the reader.
seq:
  - id: magic
    contents: "ARCV"
  - id: num_entries
    type: u4
    doc: Number of 12-byte member descriptors; must be nonzero for extraction.
  - id: len_file
    type: u4
    doc: Declared whole-file length; extractor requires it to match actual size.
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: ofs_body
        type: u4
        doc: Absolute member offset; extractor requires it at or after the table.
      - id: len_body
        type: u4
        doc: Member byte length; the full range must remain inside the file.
      - id: crc32
        type: u4
        doc: zlib CRC32 of raw bytes in writer output; extractor does not check it.
    instances:
      body:
        io: _root._io
        pos: ofs_body
        size: len_body
        doc: Raw unnamed member bytes; format-specific decoding is separate.
