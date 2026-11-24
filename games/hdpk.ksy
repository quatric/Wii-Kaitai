meta:
  id: hdpk
  title: Nintendo Channel HDPK compiled table schema
  file-extension: bin
  endian: be
doc: |
  Nintendo Channel `HDPK001B` compiled table schemas (e.g. the `xml/*.bin` files
  of the Wii no Ma / Nintendo Channel family). After a record table come the
  NUL-separated table and column names, a u32 offset table into them and the
  `CHECKDATA` / `VERSION` markers. The record table is not decoded.
seq:
  - id: magic
    contents: HDPK
  - id: version
    contents: '001B'
  - id: len_file
    type: u4
  - id: data_offset
    type: u4
