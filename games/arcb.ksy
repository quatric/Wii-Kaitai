meta:
  id: arcb
  title: Sega ARCB archive (Super Monkey Ball Banana Blitz .arc)
  file-extension: arc
  endian: be
  imports:
    - ../other/avlz
doc: |
  Sega's "ARCB" archive (`.arc`; Super Monkey Ball: Banana Blitz -- 417 of its
  426 archives verified). A 0x20-byte ARCB header, then a standard U8 tree
  whose file data is a single AVLZ-compressed block.

  U8 node data offsets and sizes are relative to the *unpacked* data block. The
  data block sits at `0x20 + u8.data_offset` and starts with `AVLZ`. Differences
  from a plain U8: the node name offset is 24 bits (the top byte is the node
  kind), and bit 31 of a file node's offset flags a packed member.
seq:
  - id: magic
    contents: 'ARCB'
  - id: version
    type: u4
    doc: 0x03010000.
  - id: flags
    type: u4
  - id: file_size
    type: u4
  - id: data_start
    type: u4
  - id: sizes
    type: u4
  - id: file_size_again
    type: u4
  - id: zero
    type: u4
  - id: tree
    type: u8_tree
instances:
  data_block:
    pos: 0x20 + tree.data_offset
    type: avlz
    doc: The AVLZ block holding every member's data.
types:
  u8_tree:
    seq:
      - id: magic
        contents: [0x55, 0xaa, 0x38, 0x2d]
      - id: root_offset
        type: u4
        doc: Offset of node 0 from the start of the U8 tree (>= 0x20).
      - id: fst_size
        type: u4
        doc: Node table plus string pool size.
      - id: data_offset
        type: u4
        doc: Offset of the AVLZ block from the start of the U8 tree.
      - id: reserved
        size: 16
    instances:
      nodes:
        pos: 0x20 + root_offset
        type: node
        repeat: expr
        repeat-expr: num_nodes
        io: _root._io
      num_nodes:
        value: root_node.size_or_next
      root_node:
        pos: 0x20 + root_offset
        type: node
        io: _root._io
      names:
        pos: 0x20 + root_offset + 12 * num_nodes
        size: fst_size - 12 * num_nodes
        io: _root._io
        doc: NUL-separated name pool; node `name_offset` indexes into it.
  node:
    seq:
      - id: kind
        type: u1
        doc: 0 = file, 1 = directory.
      - id: name_offset
        type: b24
        doc: 24-bit offset into the name pool.
      - id: offset_or_parent
        type: u4
        doc: |
          File: offset into the unpacked data block, with bit 31 flagging a
          packed member. Directory: parent node index.
      - id: size_or_next
        type: u4
        doc: |
          File: length. Directory: index one past its last child.
    instances:
      offset:
        value: offset_or_parent & 0x7fffffff
      is_packed:
        value: (offset_or_parent & 0x80000000) != 0
