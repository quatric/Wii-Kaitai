meta:
  id: luxor_ppk
  title: Luxor PRPK pack (.PPK)
  file-extension: ppk
  endian: le
doc: |
  Luxor `PRPK` pack (`ASSETS_WII/*.PPK`). 64-byte nodes start at 0x30. Directory
  nodes (flags bit 16) form a tree through the parent index. Data offsets are
  0x80 aligned. The node count is not stored in the header nintoolbox reads, so
  nodes are not declared with a count.
seq:
  - id: magic
    contents: PRPK
  - id: len_file
    type: u4
  - id: reserved
    size: 0x28
types:
  node:
    seq:
      - id: crc
        type: u4
      - id: flags
        type: u4
        doc: Bit 16 = directory.
      - id: parent
        type: u2
        doc: 0xFFFF = none.
      - id: link
        type: u2
      - id: unknown
        type: u4
      - id: data_offset
        type: u4
      - id: len_data
        type: u4
      - id: name
        size: 0x28
        type: strz
        encoding: ASCII
