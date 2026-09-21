meta:
  id: yay0
  endian: be
  title: Nintendo Yay0 compressed stream
doc: |
  Nintendo Yay0 LZ-style compressed stream, per lib-yay0.c. Used by
  several first-party GameCube/Wii formats. The three-section
  (mask/link-table/chunk-data) bitstream body is not modeled here.
seq:
  - id: magic
    contents: "Yay0"
  - id: uncompressed_size
    type: u4
  - id: link_table_offset
    type: u4
  - id: chunk_data_offset
    type: u4
  - id: body
    size-eos: true
