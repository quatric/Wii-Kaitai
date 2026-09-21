meta:
  id: camelot
  file-extension:
    - stpl
    - camelot
  endian: be
  title: Camelot LZ-compressed stream
doc: |
  A simple LZSS-style compression stream used by Camelot Software Planning
  (Mario Golf: Toadstool Tour, Mario Power Tennis, Mario Golf/Tennis) to
  pack their models and texture banks (see camtexbank.ksy) inside
  relocatable PPC modules on GameCube/Wii.

  The 4-byte header is a 1-byte format flag (only 1 and 2 are seen; both
  decode identically in the reference tool) followed by a 24-bit
  big-endian uncompressed size. What follows is a byte-oriented LZ
  stream: each "flags" byte selects, bit by bit (MSB first) for the next
  8 tokens, either a literal byte or a back-reference. A back-reference
  is 2 bytes -- the top nibble of the distance and a 4-bit length packed
  into the first byte, the low byte of the distance in the second --
  with length 0 meaning "read one more byte for length-17"; a distance
  that reaches before the start of the output reads as zero (Camelot's
  window is implicitly zero-filled before the first output byte, and
  real files are seen relying on that). The stream is not modeled token
  by token here since it is a bitstream, not a byte-aligned structure;
  only the fixed header is.
seq:
  - id: format
    type: u1
    valid:
      any-of: [1, 2]
    doc: Stream format flag; both values observed in practice decode the same way.
  - id: uncompressed_size
    type: b24
    doc: Size in bytes of the fully decompressed output.
  - id: compressed_data
    size-eos: true
    doc: LZ-compressed token stream (bit-packed flags + literals/back-references); not modeled here.
