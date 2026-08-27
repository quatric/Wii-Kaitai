meta:
  id: fzip
  file-extension: fzip
  endian: be
  title: Game & Wario FZIP compressed container
doc: |
  FZIP compression format used in Game & Wario (Wii U).
  A lightweight container consisting of an 8-byte header (magic 'FZIP'
  and a 32-bit big-endian uncompressed size) followed by a standard
  zlib-compressed stream (RFC 1950 / RFC 1951 Deflate).

  Used to compress WARC archives (.warc), BFRES models, BFLIM textures,
  and layout assets.
seq:
  - id: magic
    contents: "FZIP"
    doc: ASCII magic signature 'FZIP' (0x465A4950)
  - id: uncompressed_size
    type: u4
    doc: Total uncompressed byte size of the decompressed payload
  - id: compressed_payload
    size-eos: true
    process: zlib
    doc: Zlib-compressed payload stream
