meta:
  id: szs_yaz0
  endian: be
  title: Nintendo Yaz0/Yaz1 compressed stream (SZS)
doc: |
  Nintendo Yaz0/Yaz1 LZ-style compressed stream, per `yaz0_header_t`
  in lib-szs.h. Used throughout Wii/GameCube titles to wrap U8
  archives (.szs) and other files. The LZSS-derived bitstream body
  is not modeled here.
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
    valid:
      any-of: ['"Yaz0"', '"Yaz1"', '"xYz0"']
  - id: uncompressed_size
    type: u4
  - id: padding
    size: 8
  - id: compressed_data
    size-eos: true
