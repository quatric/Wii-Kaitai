meta:
  id: pers
  title: Pokemon Stadium (N64) PERS-SZP container
  endian: be
  license: CC0-1.0

doc: |
  Pokemon Stadium (N64) archive wrapper. An 8-byte "PERS-SZP" magic followed
  by a big-endian header giving the header size and the decompressed payload
  size, then a Yay0-compressed stream (magic "Yay0") starting at
  `header_size`. The header size independently states the decompressed size,
  which must equal what the Yay0 stream itself decodes to.

  Reference: nintoolbox project/src/lib-pers.c (ExtractPERSFile). This
  repository has no separate Yay0 .ksy yet, so the compressed stream is
  exposed as raw bytes only.

seq:
  - id: magic
    contents: "PERS-SZP"
  - id: header_size
    type: u4
  - id: decompressed_size
    type: u4
  - id: reserved
    size: header_size - 0x10
    if: header_size > 0x10
  - id: yay0_stream
    size-eos: true
