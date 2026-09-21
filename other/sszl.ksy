meta:
  id: sszl
  endian: le
  title: Namco Museum SSZL LZSS0 compressed stream
doc: |
  Namco Museum "SSZL" LZSS0-compressed stream, per lib-sszl.c. The
  ring-buffer LZSS bitstream body is not modeled here.
seq:
  - id: magic
    contents: "SSZL"
  - id: unknown_04
    size: 4
  - id: compressed_size
    type: u4
  - id: uncompressed_size
    type: u4
  - id: compressed_data
    size: compressed_size
