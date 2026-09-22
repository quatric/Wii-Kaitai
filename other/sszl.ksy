meta:
  id: sszl
  endian: le
  title: Namco Museum SSZL LZSS0 compressed stream
doc: |
  Namco Museum "SSZL" LZSS0-compressed stream, per lib-sszl.c. The
  ring-buffer LZSS bitstream body is not modeled here.

  The decoder starts with a zero-filled 4096-byte history ring and write
  cursor 0xfee. It consumes flag bytes least-significant bit first. A set
  flag copies one literal byte into both the output and ring. A clear flag
  reads two bytes: the first byte and the high nibble of the second form a
  12-bit ring position; the low nibble plus three gives a copy length of
  3..18. Source and destination ring positions advance during the copy, so
  overlapping references and references to the initial zero fill are valid.
  Decoding stops exactly at `uncompressed_size` output bytes, even if the
  declared compressed region still has bytes remaining.

  nintoolbox rejects a zero or excessive output length, a compressed region
  beyond EOF, truncated tokens, and matches that would exceed the declared
  output length. Its encoder emits only literal tokens in groups of up to
  eight under a 0xff flag byte; that is a valid but uncompressed form of the
  same token grammar. The header word at 0x04 is written as zero and ignored
  by the decoder, so preserve non-zero values if encountered.
seq:
  - id: magic
    contents: "SSZL"
    doc: Four-byte ASCII signature.
  - id: unknown_04
    size: 4
    doc: Header word written as zero by nintoolbox; decoder does not inspect it.
  - id: compressed_size
    type: u4
    doc: Length of the token stream beginning at file offset 0x10.
  - id: uncompressed_size
    type: u4
    doc: Exact output length required from the LZSS token stream.
  - id: compressed_data
    size: compressed_size
    doc: Flag bytes, literal bytes, and two-byte ring-copy tokens.
