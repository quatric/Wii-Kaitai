meta:
  id: ubiipk
  title: Ubisoft UbiArt IPK bundle (Just Dance, v5 Wii)
  file-extension: ipk
  endian: be
doc: |
  Entries start at 0x2c; the table ends at `base_offset` and data offsets are
  absolute. Members with a compressed size are not zlib.
seq:
  - id: magic
    contents: [0x50, 0xec, 0x12, 0xba]
  - id: version
    type: u4
  - id: platform
    type: u4
  - id: base_offset
    type: u4
  - id: file_count
    type: u4
  - id: unk
    size: 0x2c - 0x14
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: file_count
types:
  entry:
    seq:
      - id: id
        type: u4
      - id: offset_count
        type: u4
      - id: size
        type: u4
      - id: compressed_size
        type: u4
      - id: timestamp
        type: u8
      - id: offsets
        type: u8
        repeat: expr
        repeat-expr: offset_count
      - id: name_length
        type: u4
      - id: name
        size: name_length
        type: str
        encoding: ASCII
      - id: path_length
        type: u4
      - id: path
        size: path_length
        type: str
        encoding: ASCII
      - id: checksum
        type: u4
