meta:
  id: lzmabrtex
  title: LZMA-wrapped BRRES texture pack (.brtex)
  file-extension: brtex
doc: |
  TV Show King Party, We Sing, Showtime Championship Boxing. 6-byte prefix
  "\xffLZMA\0" followed by a standard LZMA-alone stream (props, dictionary size,
  8-byte size). The decompressed data is a BRRES.
seq:
  - id: magic
    contents: [0xff, "LZMA", 0]
  - id: lzma_props
    size: 1
  - id: dictionary_size
    type: u4le
  - id: uncompressed_size
    type: u8le
  - id: stream
    size-eos: true
