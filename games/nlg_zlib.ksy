meta:
  id: nlg_zlib
  title: Next Level Games .zlib wrapper
  file-extension: zlib
  endian: be
doc: |
  Next Level Games `.zlib` wrapper (Mario Strikers Charged `*.sanim.zlib`):
  the big-endian decompressed size followed by a plain zlib stream.
seq:
  - id: len_unpacked
    type: u4
  - id: zlib_stream
    size-eos: true
