meta:
  id: lclpool
  title: Phineas and Ferb Across the 2nd Dimension .lcl
  file-extension: lcl
  endian: be
doc: '{u32 record count, records of hashes and string offsets, ...} then a pool of NUL-terminated UTF-8 strings starting at the first string offset.'
seq:
  - id: record_count
    type: u4
  - id: rest
    size-eos: true
