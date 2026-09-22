meta:
  id: ccf
  endian: be
  title: Wii Virtual Console CCF archive
doc: |
  Wii Virtual Console "CCF" flat archive, per lib-vc.c (WiiBrew
  "CCF archive" page, cross-checked against paulguy/ccf-tools).
  Optional per-entry zlib (standard, not raw-deflate) compression;
  a member is stored raw when size == decompressed_size.

  The 32-byte header is followed immediately by num_files 32-byte
  descriptors. Offsets in those descriptors are multiplied by the header's
  offset_multiplier to obtain absolute file positions. There is no explicit
  data-start pointer; members may be separated by alignment padding.

  nintoolbox's reader requires a nonzero multiplier, 1..65536 descriptors,
  a complete table, and each declared stored payload wholly inside the
  file. It copies all 20 filename bytes and appends a NUL if no terminator
  is present. When the stored and decompressed sizes differ, decoding expects
  a complete standard zlib stream that produces exactly decompressed_size
  bytes; this schema exposes the stored stream without inflating it.

  The nintoolbox writer uses multiplier 32, aligns every payload to 32 bytes,
  zero-fills reserved header bytes and padding, and stores at most 20 basename
  bytes per entry. With compression enabled, it tries zlib level 6 only for
  inputs longer than 32 bytes and keeps the compressed stream only if it is
  smaller. These are writer choices, not requirements for other CCF files.
  The layout has been cross-checked against public format descriptions, but
  the nintoolbox implementation notes that it has not yet been verified
  against a real CCF-magic sample.
seq:
  - id: magic
    contents: "CCF\0"
  - id: unknown_04
    size: 12
    doc: Reserved header bytes; zero in nintoolbox output.
  - id: offset_multiplier
    type: u4
    doc: Unit size for entry offsets; must be nonzero for nintoolbox's reader.
  - id: num_files
    type: u4
    doc: Descriptor count; nintoolbox's reader accepts 1 through 65536.
  - id: unknown_18
    size: 8
    doc: Reserved header bytes; zero in nintoolbox output.
  - id: entries
    type: entry_t
    repeat: expr
    repeat-expr: num_files
types:
  entry_t:
    seq:
      - id: name
        type: str
        size: 20
        encoding: ASCII
        terminator: 0
        doc: Fixed-width filename bytes; may occupy all 20 bytes without a NUL.
      - id: offset_units
        type: u4
        doc: Payload file position measured in offset_multiplier-sized units.
      - id: size
        type: u4
        doc: Stored payload byte length, compressed or raw.
      - id: decompressed_size
        type: u4
        doc: Expected decoded length; equality with size signals raw storage.
    instances:
      offset:
        value: offset_units * _root.offset_multiplier
        doc: Absolute byte offset of this member's stored payload.
      body:
        pos: offset
        size: size
        io: _root._io
        doc: Stored member bytes; zlib decoding is not performed here.
