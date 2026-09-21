meta:
  id: szs_u8
  endian: be
  title: Nintendo U8 archive (SZS payload)
doc: |
  Nintendo U8 directory archive, per `u8_header_t`/`u8_node_t` in
  lib-szs.h. Almost always found Yaz0-compressed as a ".szs" file
  (see szs_yaz0.ksy); this definition covers the decompressed U8
  container itself. The node table is a flat pre-order walk of the
  directory tree; each directory node's `offset` field is the index
  of the node one past its last descendant, and names are pulled
  from a string table right after the node array.
seq:
  - id: magic
    contents: [0x55, 0xaa, 0x38, 0x2d]
  - id: node_offset
    type: u4
  - id: fst_size
    type: u4
    doc: Size of all nodes including the string table.
  - id: data_offset
    type: u4
  - id: padding
    size: node_offset - 0x10
instances:
  root_node:
    pos: node_offset
    type: node_t
types:
  node_t:
    seq:
      - id: name_off_and_flag
        type: u4
        doc: Low 3 bytes are the string-table offset; the high byte is the is_dir flag.
      - id: offset
        type: u4
        doc: File data offset, or (for directories) the index of the node past the subtree.
      - id: size
        type: u4
    instances:
      is_dir:
        value: (name_off_and_flag >> 24) != 0
      name_offset:
        value: name_off_and_flag & 0x00ffffff
