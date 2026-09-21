meta:
  id: cmpd
  endian: be
  title: Retro Studios CMPD compression wrapper (used inside RPAK)
doc: |
  "CMPD" block-compressed wrapper for an RPAK entry payload, per
  DecompressRPAKEntry() in lib-rpak.c. Each block header packs a
  24-bit stored size across 3 bytes plus a compression-method byte;
  block bodies are zlib-deflate streams, not decoded here.
seq:
  - id: magic
    contents: "CMPD"
  - id: num_blocks
    type: u4
  - id: blocks
    type: block_header_t
    repeat: expr
    repeat-expr: num_blocks
types:
  block_header_t:
    seq:
      - id: method
        type: u1
      - id: stored_size_hi
        type: u1
      - id: stored_size_mid
        type: u1
      - id: stored_size_lo
        type: u1
      - id: uncompressed_size
        type: u4
    instances:
      stored_size:
        value: (stored_size_hi << 16) | (stored_size_mid << 8) | stored_size_lo
