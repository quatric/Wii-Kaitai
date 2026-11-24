meta:
  id: ntcompress
  title: ntcompress2 wrapper (.crfnt)
  file-extension: crfnt
doc: 'A 0x20-byte ASCII banner ("created by ntcompress2") followed by a standard Nintendo LZ10/LZ11 stream.'
seq:
  - id: banner
    size: 0x20
    type: strz
    encoding: ASCII
  - id: lz_stream
    size-eos: true
