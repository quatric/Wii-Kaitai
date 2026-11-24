meta:
  id: fezc
  title: FEZC file package (GVF engine WiiWare, .fez)
  file-extension: fez
  endian: le
doc: |
  Yard Sale Hidden Treasures etc. Record flags 0x102 = zlib stream
  (sync-flushed, no final block), 0 = stored.
seq:
  - id: magic
    contents: FEZC
  - id: version
    type: u4
    doc: 0x10000.
  - id: file_count
    type: u4
  - id: names_offset
    type: u4
    doc: 0x28.
  - id: records_offset
    type: u4
  - id: data_offset
    type: u4
  - id: header_hash
    size: 0x28 - 0x18
instances:
  names:
    pos: names_offset
    type: name
    repeat: expr
    repeat-expr: file_count
  records:
    pos: records_offset
    type: record
    repeat: expr
    repeat-expr: file_count
types:
  name:
    seq:
      - id: padded_len
        type: u4
      - id: path
        size: padded_len
        type: strz
        encoding: ASCII
  record:
    seq:
      - id: flags
        type: u4
      - id: offset
        type: u4
      - id: compressed_size
        type: u4
      - id: uncompressed_size
        type: u4
      - id: md5
        size: 16
    instances:
      body:
        pos: offset
        size: compressed_size
        io: _root._io
