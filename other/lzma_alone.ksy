meta:
  id: lzma_alone
  endian: le
doc: |
  Standalone ".lzma" stream, ported from lib-lzma.c/.h (Wiimms SZS
  Tools wrapper around liblzma). Fixed 13-byte header: 5 property
  bytes (1 byte encoding lc/lp/pb, then a 4-byte dictionary size) plus
  an 8-byte little-endian uncompressed size (0xFFFFFFFFFFFFFFFF when
  unknown/streamed), followed by the raw LZMA-compressed range-coder
  stream. This project's `EncodeLZMA()`/`DecodeLZMAbin()` optionally
  add a caller-chosen number of extra header bytes ahead of this (not
  modeled, since that count isn't stored in the stream itself) and
  `DecodeLZMAsize()` instead expects a leading 4-byte size prefix in
  front of this whole header. `IsLZMA()` also recognises the plain
  3-byte prefix 0x5D 0x00 0x00 (LZMA_MAGIC_NUM3, i.e. properties byte
  0x5D = lc3/lp0/pb2) as a heuristic signature.
seq:
  - id: properties
    type: u1
    doc: '(pb * 5 + lp) * 9 + lc, i.e. 0x5D for the common lc=3,lp=0,pb=2.'
  - id: dict_size
    type: u4
  - id: uncompressed_size
    type: u8
    doc: 0xFFFFFFFFFFFFFFFF means unknown (streamed end-of-stream marker used instead).
  - id: compressed_stream
    size-eos: true
