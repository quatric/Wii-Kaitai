meta:
  id: jppak
  title: Junction Point / Gamebryo .pak (Epic Mickey)
  file-extension: pak
  endian: be
doc: |
  Junction Point / Gamebryo `.pak` resource pack (Disney Epic Mickey, Wii). 24-byte
  entries start at 0x20, then a u32 and the NUL-separated name pool (names are
  `<directory>/<file>`) and, at `0x20 + table size`, the members back to back
  (each padded to 0x20). Members whose size differs from their compressed size
  are zlib streams. The entry count is found by summing the padded sizes until
  they fill the file, so entries are not declared with a count here.
seq:
  - id: magic
    contents: [0x20, 0x4b, 0x41, 0x50]
  - id: version
    type: u4
    doc: 2.
  - id: zero0
    type: u4
  - id: header_size
    type: u4
    doc: 0x20.
  - id: len_table
    type: u4
  - id: zeros
    size: 12
types:
  entry:
    seq:
      - id: file_name_offset
        type: u4
      - id: len_size
        type: u4
      - id: len_compressed
        type: u4
      - id: len_compressed_padded
        type: u4
        doc: Compressed size rounded to 0x20.
      - id: directory_name_offset
        type: u4
      - id: type_tag
        size: 4
        doc: Four characters, or 0.
