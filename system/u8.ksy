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
    doc: Big-endian U8 signature, 0x55aa382d.
  - id: root_node_offset
    type: u4
    doc: >-
      Absolute offset of node 0 (the root directory).  Nintendo archives use
      0x20; nintoolbox may align this later to retain a padded header.
  - id: header_size
    type: u4
    doc: >-
      FST size in bytes: the node table plus its following string pool.  This
      range begins at root_node_offset; it does not include header padding or
      the file-data area.
  - id: data_offset
    type: u4
    doc: >-
      Absolute offset at which the file-data area begins.  It is usually
      alignment-padded after the FST, but individual file nodes retain their
      own absolute offsets and need not be physically ordered.
  - id: reserved
    size: 16
    doc: >-
      Initial reserved header area (offsets 0x10..0x1f).  If root_node_offset
      is larger than 0x20, further bytes before the node table are likewise
      header padding; nintoolbox fills added padding with 0xcc.
instances:
  root:
    pos: root_node_offset
    type: node
    doc: >-
      Root directory node.  Its size_or_next value is the node count and
      therefore drives parsing of the complete flat node table.
  num_nodes:
    value: root.size_or_next
    doc: >-
      Total number of nodes, read from the root directory's exclusive-end
      index.  This includes the root node itself.
  string_table_offset:
    value: root_node_offset + num_nodes * 12
    doc: >-
      Start of the NUL-terminated name pool, immediately after all 12-byte
      node records.  name_offset values are relative to this position.
  nodes:
    pos: root_node_offset
    type: node
    repeat: expr
    repeat-expr: num_nodes
    doc: >-
      Preorder node table.  Directories use exclusive node indexes to bound
      their descendant subtrees, so nesting comes from table order rather
      than child-pointer lists.
types:
  node:
    seq:
      - id: kind
        type: u1
        enum: node_kind
        doc: >-
          Node kind byte.  The remaining 24 bits of this first word form
          name_offset; only file (0) and directory (1) are valid kinds.
      - id: name_offset
        type: b24
        doc: >-
          24-bit offset into the root string pool.  The root normally uses
          zero for its empty name; other nodes name a NUL-terminated string.
      - id: data_offset_or_parent
        type: u4
        doc: >-
          For a file, absolute offset of its payload.  For a directory,
          parent node index (the root conventionally stores zero).
      - id: size_or_next
        type: u4
        doc: >-
          For a file, payload size in bytes.  For a directory, the exclusive
          index one past its complete preorder subtree; it is not a byte size.
    instances:
      name:
        io: _root._io
        pos: _root.string_table_offset + name_offset
        type: strz
        encoding: UTF-8
        if: name_offset != 0 or kind == node_kind::directory
        doc: >-
          Resolved UTF-8 NUL-terminated name.  Real archives can contain raw
          Shift-JIS or other non-UTF-8 names; callers handling those should
          use the original bytes rather than rely on text conversion.
      body:
        io: _root._io
        pos: data_offset_or_parent
        size: size_or_next
        if: kind == node_kind::file
        doc: >-
          Raw file payload, resolved by the file-node offset/size pair.  No
          directory node has a body at data_offset_or_parent.
    enums:
      node_kind:
        0: file
        1: directory
