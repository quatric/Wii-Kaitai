meta:
  id: wii_u8
  title: Nintendo U8 archive
  file-extension: arc
  endian: be
doc: |
  U8 is the archive behind `.arc`/`.app` layout and resource bundles on Wii. A flat table
  of 12-byte nodes is followed by a string table; the first node is the root directory and
  its `size_or_next` is the total node count.

    file node       kind 0, data_offset_or_parent = absolute file offset, size_or_next = length
    directory node  kind 1, data_offset_or_parent = parent node index,
                    size_or_next = index one past the last node of this directory

  Names are NUL-terminated strings at `string_table_offset + name_offset`. Many channels
  store U8 archives inside an LZ77/LZ11 wrapper: decompress first. The 27 MB data archive
  of the Today & Tomorrow Channel (content 6) is a plain U8 with 134 nodes.
seq:
  - id: magic
    contents: [0x55, 0xaa, 0x38, 0x2d]
  - id: root_node_offset
    type: u4
    doc: always 0x20 in practice
  - id: header_size
    type: u4
    doc: size of the node table plus string table
  - id: data_offset
    type: u4
  - id: reserved
    size: 16
instances:
  root:
    pos: root_node_offset
    type: node
  num_nodes:
    value: root.size_or_next
  string_table_offset:
    value: root_node_offset + num_nodes * 12
  nodes:
    pos: root_node_offset
    type: node
    repeat: expr
    repeat-expr: num_nodes
types:
  node:
    seq:
      - id: kind
        type: u1
        enum: node_kind
      - id: name_offset
        type: b24
      - id: data_offset_or_parent
        type: u4
      - id: size_or_next
        type: u4
    instances:
      name:
        io: _root._io
        pos: _root.string_table_offset + name_offset
        type: strz
        encoding: UTF-8
        if: name_offset != 0 or kind == node_kind::directory
      body:
        io: _root._io
        pos: data_offset_or_parent
        size: size_or_next
        if: kind == node_kind::file
    enums:
      node_kind:
        0: file
        1: directory
