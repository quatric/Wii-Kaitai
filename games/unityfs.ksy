meta:
  id: unityfs
  title: Unity UnityFS asset bundle
  file-extension: unity3d
  endian: be
doc: |
  Unity 5.3+. Flags: bits 0-5 block-info compression (0 none, 1 LZMA, 2 LZ4,
  3 LZ4HC), 0x40 directory inside block info, 0x80 block info at end of file,
  0x100 old-web padding, 0x200 block info aligned to 16. Block info: 16-byte
  hash, u32 block count, {u32 uncomp, comp, u16 flags} per block, u32 node
  count, {i64 offset, i64 size, u32 flags, cstr path} per node.
seq:
  - id: magic
    contents: ["UnityFS", 0]
  - id: version
    type: u4
  - id: player_version
    type: strz
    encoding: UTF-8
  - id: engine_version
    type: strz
    encoding: UTF-8
  - id: total_size
    type: s8
  - id: blockinfo_comp_size
    type: u4
  - id: blockinfo_uncomp_size
    type: u4
  - id: flags
    type: u4
  - id: rest
    size-eos: true
types:
  block_info:
    seq:
      - id: hash
        size: 16
      - id: block_count
        type: u4
      - id: blocks
        type: block
        repeat: expr
        repeat-expr: block_count
      - id: node_count
        type: u4
      - id: nodes
        type: node
        repeat: expr
        repeat-expr: node_count
  block:
    seq:
      - id: uncompressed_size
        type: u4
      - id: compressed_size
        type: u4
      - id: flags
        type: u2
  node:
    seq:
      - id: offset
        type: s8
      - id: size
        type: s8
      - id: flags
        type: u4
      - id: path
        type: strz
        encoding: UTF-8
