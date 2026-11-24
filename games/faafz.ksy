meta:
  id: faafz
  title: Monkey-Bar chunked LZF container
  endian: be
doc: |
  Maps, regions, entity templates... named by a 64-bit hash. 8-byte file type
  hash, u32 unpacked size, u32 offset count n, n offsets (the first is 0x10 +
  4n, bit 31 marks a stored chunk, the last is the packed size), then n - 1
  liblzf chunks each unpacking to 0x8000 bytes except the last. The unpacked
  result is the "FA AF FA AF" object container (version 3 / 7, closing
  "FE EF FE EF").
seq:
  - id: file_type_hash
    size: 8
  - id: unpacked_size
    type: u4
  - id: offset_count
    type: u4
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: offset_count
  - id: chunks
    size-eos: true
