meta:
  id: pers
  title: Pokemon Stadium (N64) PERS-SZP container
  endian: be
  license: CC0-1.0
  imports:
    - yay0

doc: |
  Pokemon Stadium (N64) archive wrapper. An 8-byte "PERS-SZP" magic followed
  by a big-endian header giving the header size and the decompressed payload
  size, two additional observed header words, optional header-extension bytes,
  then a Yay0-compressed stream starting at `header_size`. The header size
  independently states the decompressed size, which must equal what the Yay0
  stream itself decodes to.

  nintoolbox requires a file at least 0x20 bytes long, `header_size >= 0x18`,
  a non-zero declared output size, a header ending before EOF, and `Yay0` at
  that exact offset. It rejects a stream whose decoded size disagrees with
  `decompressed_size`. The semantics of the two words at 0x10 and 0x14 are
  still unknown: the supplied all-literal regression fixture sets them to the
  decompressed size and zero respectively, while the extractor does not read
  either.

seq:
  - id: magic
    contents: "PERS-SZP"
    doc: Eight-byte ASCII signature `PERS-SZP`.
  - id: header_size
    type: u4
    doc: Absolute offset of the embedded Yay0 stream. The extractor requires
      at least 0x18 bytes of header.
  - id: decompressed_size
    type: u4
    doc: Required decoded output length; independently checked against Yay0.
  - id: unknown_10
    type: u4
    doc: Observed header word at 0x10. Its semantics are not established;
      the all-literal test fixture stores the decoded size here.
  - id: unknown_14
    type: u4
    doc: Observed header word at 0x14. Its semantics are not established;
      the all-literal test fixture stores zero here.
  - id: reserved
    size: header_size - 0x18
    if: header_size > 0x18
    doc: Unparsed extension bytes for headers larger than the known 0x18-byte
      base header.
  - id: yay0_stream
    type: yay0
    size-eos: true
    doc: Embedded Nintendo Yay0 stream. Its own `uncompressed_size` must equal
      `decompressed_size` for a valid PERS container.
