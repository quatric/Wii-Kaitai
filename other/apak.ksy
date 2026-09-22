meta:
  id: apak
  file-extension: apak
  title: Nintendo APAK archive
doc: |
  A flat archive with a 24-byte header and fixed 64-byte entries. Written
  by this tool always as big-endian version 5; endianness is detected on
  read from the version field at offset 6, which reads as big-endian 5
  when the whole file is big-endian.

  nintoolbox extracts .apak and .bin files with APAK magic. It chooses
  big-endian only when the version probe equals 5; every other probe is
  interpreted as little-endian without validating a little-endian version.
  The reader requires 1..100000 entries and a complete 64-byte-per-entry
  table. It ignores the file-info byte count and reserved words, skips a
  member whose absolute offset is at or beyond EOF, and truncates a member
  whose declared length extends past EOF. Empty on-disk names become
  file_NNNN.bin, where NNNN is the zero-based descriptor index.

  The writer sorts input entries, strips directory prefixes from names,
  writes version 5 in big-endian order, and sets len_file_info to
  num_files * 64. It aligns the first payload and every following payload
  to 32 bytes, zero-filling header, descriptor, and inter-payload padding.
  The reader does not require that alignment. This schema returns raw
  declared bodies rather than applying the extractor's EOF clamping.
seq:
  - id: magic
    contents: "APAK"
  - id: unknown0
    size: 2
    doc: Reserved header bytes; zero in writer output.
  - id: version_be_probe
    type: u2be
    doc: Read big-endian to detect overall endianness; 5 means the file is big-endian.
  - id: content
    type:
      switch-on: version_be_probe
      cases:
        5: body(false)
        _: body(true)
types:
  body:
    params:
      - id: is_le
        type: bool
    meta:
      endian:
        switch-on: is_le
        cases:
          true: le
          false: be
    seq:
      - id: num_files
        type: u4
        doc: Number of 64-byte member descriptors.
      - id: unknown1
        type: u4
        doc: Reader-ignored header word; zero in writer output.
      - id: len_file_info
        type: u4
        doc: Nominal table byte size; writer uses num_files * 64, reader ignores it.
      - id: unknown2
        type: u4
        doc: Reader-ignored header word; zero in writer output.
      - id: entries
        type: entry
        repeat: expr
        repeat-expr: num_files
    types:
      entry:
        seq:
          - id: unknown0
            size: 4
            doc: Reader-ignored record prefix; zero in writer output.
          - id: ofs_body
            type: u4
            doc: Absolute payload byte offset.
          - id: len_body
            type: u4
            doc: Declared payload byte length, subject to extractor EOF clamping.
          - id: unknown1
            size: 20
            doc: Reader-ignored record bytes; zero in writer output.
          - id: name
            type: strz
            encoding: ASCII
            size: 32
            doc: Fixed 32-byte member path; a full slot need not contain a NUL.
        instances:
          body:
            io: _root._io
            pos: ofs_body
            size: len_body
            doc: Raw declared member bytes; no EOF clamping is performed here.
