meta:
  id: ibz_zlib
  title: Jimmie Johnson IBZ zlib file (.ibz)
  file-extension: ibz
  endian: le
doc: |
  Jimmie Johnson's Anything with an Engine (Wii) `*.ibz`: the uncompressed size
  followed by one zlib stream. The inflated data (e.g. `ISOP` configuration data)
  is extracted recursively.
seq:
  - id: len_uncompressed
    type: u4
  - id: zlib_stream
    size-eos: true
