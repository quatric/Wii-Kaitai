meta:
  id: mtxz
  title: MTXZ zlib wrapper (Shin Chan Wii .mz)
  file-extension: mz
  endian: be
doc: |
  `MTXZ` (Shin Chan Wii `*.mz`): a zlib stream at 0x10 whose inflated data is the
  payload.
seq:
  - id: magic
    contents: MTXZ
  - id: zero0
    type: u4
  - id: len_decompressed
    type: u4
  - id: zero1
    type: u4
  - id: zlib_stream
    size-eos: true
