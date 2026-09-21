meta:
  id: bns
  file-extension: bns
  endian: be
  title: Koei Tecmo LINKDATA .BNS archive (Samurai Warriors 3, Wii)
doc: |
  A flat, block-aligned data archive Koei Tecmo ships as `LINKDATA*.BNS` on
  Samurai Warriors 3 (Wii). This is unrelated to, and collides in extension
  with, the "BNS " stream-audio format some other Nintendo titles use --
  see lib-passthru.c's `is_stream_audio` check, which deliberately leaves
  magic-less `.bns` files (this format) to the native extractor in
  lib-bns.c rather than misclaiming them.

  Layout traced directly from `ScanBNS()`: a 16-byte header (whose first
  four bytes are never read/validated by the scanner) followed by a flat
  table of (block-index, size) pairs, one per entry, and the data itself
  addressed as `block_index * block_size` from the start of the file.
seq:
  - id: unused
    size: 4
    doc: Never read by `ScanBNS()`; not part of the validated header fields.
  - id: num_entries
    type: u4
  - id: block_size
    type: u4
    doc: |
      Alignment granularity for entry offsets; must be a power of two
      (`ScanBNS()` rejects the file otherwise).
  - id: reserved
    type: u4
    doc: Must be zero, or `ScanBNS()` rejects the file.
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: block_index
        type: u4
        doc: Entry offset in the file is `block_index * _root.block_size`.
      - id: len_entry
        type: u4
    instances:
      body:
        pos: block_index * _root.block_size
        size: len_entry
        if: len_entry > 0
