meta:
  id: bea
  file-extension: bea
  endian: le
  title: "Nintendo EAD \"Bezel Engine Archive\" (.bea / .nx.bea, SCNE)"
doc: |
  Nintendo EAD Tokyo's Switch archive format (WarioWare: Get It
  Together! and other titles). Reverse-engineered, no public spec;
  follows KillzXGaming/Switch-Toolbox's BezelEngineArchive_Lib layout.
  Every multi-byte field is little-endian despite the big block-header
  values; a string is always stored as an 8-byte absolute offset to a
  16-bit length-prefixed UTF-8 blob (`bea_string`). Layout past the
  fixed header depends on `version_major2`: fields present only from
  version 5 (asset offset, compression name, reference list) or only
  from version 6 (per-file `file_id1`/`file_id2`) are guarded below.
seq:
  - id: magic
    contents: "SCNE"
  - id: reserved0
    size: 4
  - id: version_major
    type: u1
  - id: version_major2
    type: u1
  - id: version_minor
    type: u1
  - id: version_minor2
    type: u1
  - id: byte_order
    type: u2
  - id: alignment
    type: u1
  - id: target_address_size
    type: u1
  - id: reserved1
    size: 16
  - id: num_files
    type: u4
  - id: num_references
    type: u4
  - id: v5_asset_offset
    type: u8
    if: version_major2 >= 5
    doc: Unused by this tool's reader.
  - id: ofs_file_info
    type: u8
  - id: ofs_dic
    type: u8
  - id: ofs_name_or_reserved
    type: u8
    doc: Archive name string offset when `version_major2 >= 5`; an unused u64 field otherwise.
  - id: ofs_compression_name
    type: u8
    if: version_major2 >= 5
  - id: v1_ofs_name
    type: u8
    if: version_major2 < 5
    doc: Archive name string offset (older layout, where `ofs_name_or_reserved` above is unused).
  - id: ofs_references
    type: u8
    if: version_major2 >= 5
instances:
  name:
    io: _root._io
    pos: version_major2 >= 5 ? ofs_name_or_reserved : v1_ofs_name
    type: bea_string
    if: (version_major2 >= 5 ? ofs_name_or_reserved : v1_ofs_name) > 0
  compression_name:
    io: _root._io
    pos: ofs_compression_name
    type: bea_string
    if: version_major2 >= 5 and ofs_compression_name > 0
  references:
    io: _root._io
    pos: ofs_references
    type: u8
    repeat: expr
    repeat-expr: num_references
    if: version_major2 >= 5 and num_references > 0 and ofs_references > 0
    doc: Each entry is itself a `bea_string` offset; not typed as one directly to avoid a double indirection here.
  dic:
    io: _root._io
    pos: ofs_dic
    type: dic_header
    if: ofs_dic > 0
  file_refs:
    io: _root._io
    pos: ofs_file_info
    type: u8
    repeat: expr
    repeat-expr: num_files
    doc: Each entry is an absolute offset to one `asst_block`.
  files:
    io: _root._io
    pos: file_refs[_index]
    type: asst_block
    repeat: expr
    repeat-expr: num_files
types:
  bea_string:
    seq:
      - id: len_str
        type: u2
      - id: str
        type: str
        encoding: UTF-8
        size: len_str
  dic_header:
    doc: On-disk Patricia-trie node table backing the archive's name lookup.
    seq:
      - id: reserved0
        type: u4
      - id: num_nodes
        type: u4
        doc: Excludes the tree's own root node.
      - id: nodes
        type: dic_node
        repeat: expr
        repeat-expr: num_nodes + 1
  dic_node:
    seq:
      - id: reference
        type: u4
      - id: idx_left
        type: u2
      - id: idx_right
        type: u2
      - id: ofs_key
        type: u8
    instances:
      key:
        io: _root._io
        pos: ofs_key
        type: bea_string
        if: ofs_key > 0
  asst_block:
    seq:
      - id: magic
        contents: "ASST"
      - id: block_offset
        type: u4
        doc: Unused by this tool's reader.
      - id: block_size
        type: u8
        doc: Unused by this tool's reader.
      - id: unk1
        type: u2
      - id: unk2
        type: u2
      - id: len_stored
        type: u4
        doc: Byte length of the (possibly zstd-compressed) stored payload.
      - id: len_decompressed
        type: u4
      - id: file_type
        type: str
        encoding: ASCII
        size: 8
        if: _root.version_major2 >= 5
      - id: unknown3
        type: u4
      - id: file_id1
        type: u8
        if: _root.version_major2 >= 6
      - id: file_id2
        type: u8
        if: _root.version_major2 >= 6
      - id: ofs_data
        type: u8
      - id: ofs_name
        type: u8
    instances:
      is_compressed:
        value: len_stored != len_decompressed
      name:
        io: _root._io
        pos: ofs_name
        type: bea_string
        if: ofs_name > 0
      data:
        io: _root._io
        pos: ofs_data
        size: len_stored
        doc: Raw when `is_compressed` is false; a zstd stream otherwise.
