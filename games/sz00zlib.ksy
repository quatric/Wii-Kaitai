meta:
  id: sz00zlib
  title: Disaster Day of Crisis SZ00 zlib container
  file-extension: ppz
  endian: le
doc: One zlib stream at 0x20; it inflates to an "ARC" archive.
seq:
  - id: magic
    contents: SZ00
  - id: uncompressed_size
    type: u4
  - id: zero
    size: 0x18
  - id: zlib_stream
    size-eos: true
