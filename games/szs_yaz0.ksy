meta:
  id: szs_yaz0
  endian: be
  title: Nintendo Yaz0/Yaz1 compressed stream (SZS)
doc: |
  Nintendo Yaz0/Yaz1 LZ-style compressed stream, per `yaz0_header_t`
  in lib-szs.h. Used throughout Wii/GameCube titles to wrap U8
  archives (.szs) and other files. `Yaz0`, `Yaz1`, and `xYz0` have the
  same 16-byte header and LZSS-derived body; the signature selects the
  family/variant rather than a different header layout.

  The decoder consumes one control byte at a time, from bit 7 to bit 0.
  A set bit copies one literal source byte. A clear bit consumes two bytes:
  the low 12 bits are a backwards distance minus one, while the high nibble
  is a length minus two. A zero high nibble consumes a third byte and makes
  the length that byte plus 0x12; otherwise matches cover lengths 3..17.
  Back-references may overlap their destination, so they must be copied
  forward byte-by-byte. Decoding ends after exactly `uncompressed_size`
  output bytes, not at compressed EOF.

  `padding` is present in Nintendo's canonical 16-byte header and writers
  normally fill it with zero, but readers should preserve rather than assume
  it: it is not part of the compression grammar. `uncompressed_size` is a
  required output bound and should be used to reject copies that underflow
  the output history or exceed the declared result.
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
    valid:
      any-of: ['"Yaz0"', '"Yaz1"', '"xYz0"']
    doc: Compression-family signature. All three variants share the modeled
      header and token grammar.
  - id: uncompressed_size
    type: u4
    doc: Exact number of bytes the token stream must produce.
  - id: padding
    size: 8
    doc: Header-reserved bytes, conventionally zero but not a decoder input.
  - id: compressed_data
    size-eos: true
    doc: Control bytes, literals, and match tokens interpreted by the Yaz
      decoder described in the format-level documentation.
