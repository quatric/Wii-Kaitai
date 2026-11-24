meta:
  id: fsg_img
  title: FreeStyleGames FSG-FILE-SYSTEM image (DISC0.IMG)
  file-extension: img
  endian: be
doc: |
  FreeStyleGames `FSG-FILE-SYSTEM` image (DJ Hero 2 `DISC0.IMG` and
  `.part0`..`partN`; the parts are concatenated). A file node's record is
  `{u32 data offset >> 10, u32 size}`, the data lying at
  `data_base_offset + (value << 10)`. Directory data is a list of NUL-terminated
  names. How `record_offset` is based is not stated in nintoolbox's comment, so
  records are not declared as instances.
seq:
  - id: magic
    size: 16
  - id: two
    type: u4
  - id: len_header
    type: u4
  - id: num_sectors
    type: u4
  - id: sector_map_offset
    type: u4
  - id: data_base_offset
    type: u4
    doc: 0x20000.
  - id: unknown
    type: u4
  - id: eight
    type: u4
  - id: num_files
    type: u4
  - id: zero
    type: u4
  - id: checksum
    type: u4
  - id: nodes
    type: node
    repeat: expr
    repeat-expr: num_files
types:
  node:
    seq:
      - id: path_hash
        type: u4
      - id: type
        type: u1
      - id: record_offset
        type: b24be
  record:
    seq:
      - id: data_offset_shr_10
        type: u4
      - id: len_data
        type: u4
