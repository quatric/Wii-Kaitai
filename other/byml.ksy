meta:
  id: byml
  file-extension:
    - byml
    - bym
  title: Nintendo BYML (binary YAML) data
doc: |
  BYML ("binary YAML") is Nintendo EAD/EPD's tree-serialization format for
  game data: hash-map/array/scalar nodes, exactly the shape of a YAML or
  JSON document, packed into a flat, offset-addressed binary blob. Seen
  throughout Wii U/Switch titles (Breath of the Wild, Splatoon, Super Mario
  Odyssey, ...) for level data, actor parameters, and save data; BotW-style
  "S"-prefixed containers (.sbyml, .smubin, ...) wrap it in Yaz0
  compression, which is not modeled here.

  The 16-byte header starts with a 2-byte magic that also fixes the
  endianness for the rest of the file: "BY" is big-endian content, "YB" is
  little-endian. After a u16 version come three absolute u32 offsets: a
  hash-key string table (the dictionary of map keys), a value string table,
  and (depending on version/layout) either the root node directly, or a
  4th u32 that turns the 3rd field into a path table and the 4th into the
  root node offset. All offsets are measured from the start of the file.

  Nodes are typed by a single leading byte:
    * 0x20/0x21   hash map keyed by a 32/64-bit hash (RELOC_* variants,
                  0x30/0x31, are the same layout, only produced by a
                  different game-side allocator)
    * 0xA0        string (value is an index into the string table)
    * 0xA1        binary blob (u32 length prefix) or, if the container
                  supports paths, an index into the path table
    * 0xA2        binary blob with an extra alignment u32 after the length
    * 0xC0        array
    * 0xC1        map, keyed by hash-key-table index
    * 0xC2        string table (used for both the key and value tables)
    * 0xC3        path array: point lists used for race courses/AI paths
    * 0xD0-0xD6   inline scalars: bool, int32, float32, uint32, int64,
                  uint64, double (the 64-bit ones store an absolute offset
                  to the actual value instead of the value itself)
    * 0xFF        null

  A container node (array/map/hashmap) begins with its own type byte plus
  a 3-byte (24-bit) child count, then a per-child type-tag/value pair whose
  layout differs by container kind: an array stores all type tags first
  (padded to a multiple of 4 bytes) followed by a parallel array of u32
  values; a map stores, per entry, a 3-byte key-table index + 1-byte type
  + u32 value; a hashmap32/64 stores, per entry, a u32/u64 hash + u32
  value, followed (after every entry) by a parallel array of type-tag
  bytes. In every case a "value" is either the payload itself (for the
  inline scalar types) or an absolute file offset to where the real node
  data lives (for strings, containers, binaries, and 64-bit scalars).

  String tables (0xC2) and path arrays (0xC3) share one sub-layout: after
  the type byte + count come count+1 u32 offsets, each relative to the
  table's own start; consecutive pairs bound one entry (a NUL-terminated
  string, or a run of 28-byte points: 6 floats -- position + normal --
  plus a trailing u32 value).
seq:
  - id: magic_bytes
    type: str
    size: 2
    encoding: ASCII
    doc: '"BY" for big-endian content, "YB" for little-endian.'
  - id: content
    type:
      switch-on: magic_bytes
      cases:
        '"BY"': body(false)
        '"YB"': body(true)
types:
  body:
    params:
      - id: is_le
        type: bool
    meta:
      endian:
        switch-on: is_le
        cases:
          true: le
          false: be
    seq:
      - id: version
        type: u2
        doc: BYML format version, 1..7 in the code that reads this back.
      - id: hash_key_table_off
        type: u4
        doc: Absolute offset of the hash-key (map key name) string table, or 0.
      - id: str_table_off
        type: u4
        doc: Absolute offset of the value string table, or 0.
      - id: field3
        type: u4
        doc: >
          Either the root node offset (older/simple layout) or, when this
          file also has a path table, the path table's offset -- see
          `root_node_off` and `path_table_off` below.
      - id: field4
        type: u4
        if: _io.size >= 20
        doc: >
          Present only in files large enough to carry it; when the layout
          turns out to support paths this is the real root node offset.
    instances:
      supports_paths:
        value: >
          field4 != null
          and (field3 == 0 or (field3 + 4 <= _io.size and hash_key_table.io.read_u1 == 0xc3))
        doc: >
          Heuristic used by the decoder: field3 is either 0 or a valid
          PATH_ARRAY (0xc3) node, and field4 points at a valid container
          node (array/map/hashmap). Approximated here; the real check also
          inspects field4's type byte.
      path_table_off:
        value: 'supports_paths ? field3 : 0'
      root_node_off:
        value: 'supports_paths ? field4 : field3'
      hash_key_table:
        io: _root._io
        pos: hash_key_table_off
        type: string_table
        if: hash_key_table_off != 0
        doc: Dictionary of map key names, indexed by the 24-bit key index stored in each map entry.
      value_string_table:
        io: _root._io
        pos: str_table_off
        type: string_table
        if: str_table_off != 0
        doc: Dictionary of string-node values, indexed by the u32 stored in a 0xa0 node.
      path_table:
        io: _root._io
        pos: path_table_off
        type: path_array
        if: 'supports_paths and path_table_off != 0'
      root_node:
        io: _root._io
        pos: root_node_off
        type: node
        if: root_node_off < _io.size
        doc: The root value of the document; almost always an array, map, or hashmap.

  # A "slot" as stored inside a container: a 1-byte type tag plus a 4-byte
  # value-or-offset. What the value means depends on the type tag, exactly
  # as in byml_parse_binary_node() in the reference decoder.
  node:
    seq:
      - id: type
        type: u1
        enum: node_type
      - id: value_raw
        type: u4
    instances:
      is_container:
        value: >
          type == node_type::array or type == node_type::map
          or type == node_type::hashmap32 or type == node_type::reloc_hashmap32
          or type == node_type::hashmap64 or type == node_type::reloc_hashmap64
      as_bool:
        value: value_raw != 0
        if: type == node_type::bool
      as_int:
        value: value_raw
        if: type == node_type::int_
      as_float:
        value: value_raw
        if: type == node_type::float_
        doc: Raw u32 bit pattern of an IEEE-754 float; reinterpret to get the value.
      string_index:
        value: value_raw
        if: type == node_type::string
      as_container:
        io: _root._io
        pos: value_raw
        type:
          switch-on: type
          cases:
            node_type::array: array_node
            node_type::map: map_node
            node_type::hashmap32: hashmap32_node
            node_type::reloc_hashmap32: hashmap32_node
            node_type::hashmap64: hashmap64_node
            node_type::reloc_hashmap64: hashmap64_node
        if: is_container
      as_binary:
        io: _root._io
        pos: value_raw
        type: binary_blob
        if: type == node_type::binary
      as_binary_aligned:
        io: _root._io
        pos: value_raw
        type: binary_blob_aligned
        if: type == node_type::binary_aligned
      as_int64:
        io: _root._io
        pos: value_raw
        type: u8
        if: type == node_type::int64
      as_uint64:
        io: _root._io
        pos: value_raw
        type: u8
        if: type == node_type::uint64
      as_double:
        io: _root._io
        pos: value_raw
        type: f8
        if: type == node_type::double_

  binary_blob:
    seq:
      - id: len
        type: u4
      - id: data
        size: len

  binary_blob_aligned:
    seq:
      - id: len
        type: u4
      - id: align
        type: u4
      - id: data
        size: len

  array_node:
    doc: >
      Header of an ARRAY (0xc0) node: count type tags (padded to a
      multiple of 4 bytes), then `count` u32 values, each paired
      positionally with the tag at the same index.
    seq:
      - id: type
        type: u1
        enum: node_type
      - id: count
        type: b24
      - id: child_types
        type: u1
        enum: node_type
        repeat: expr
        repeat-expr: (count + 3) & ~3
      - id: child_values
        type: u4
        repeat: expr
        repeat-expr: count

  map_entry:
    seq:
      - id: key_index
        type: b24
        doc: Index into the enclosing file's hash-key string table.
      - id: type
        type: u1
        enum: node_type
      - id: value_raw
        type: u4

  map_node:
    doc: >
      Header of a MAP (0xc1) node: count entries, each a 3-byte key-table
      index + 1-byte type tag + u32 value, sorted by key hash in the
      files this format is normally produced from.
    seq:
      - id: type
        type: u1
        enum: node_type
      - id: count
        type: b24
      - id: entries
        type: map_entry
        repeat: expr
        repeat-expr: count

  hashmap32_entry:
    seq:
      - id: hash
        type: u4
      - id: value_raw
        type: u4

  hashmap32_node:
    doc: >
      Header of a HASHMAP32/RELOC_HASHMAP32 (0x20/0x30) node: count
      {hash,value} pairs, followed by a parallel array of `count` type
      tags (one byte each, no padding).
    seq:
      - id: type
        type: u1
        enum: node_type
      - id: count
        type: b24
      - id: entries
        type: hashmap32_entry
        repeat: expr
        repeat-expr: count
      - id: child_types
        type: u1
        enum: node_type
        repeat: expr
        repeat-expr: count

  hashmap64_entry:
    seq:
      - id: hash
        type: u8
      - id: value_raw
        type: u4

  hashmap64_node:
    doc: >
      Header of a HASHMAP64/RELOC_HASHMAP64 (0x21/0x31) node: count
      {hash,value} pairs (12 bytes each), followed by a parallel array of
      `count` type tags.
    seq:
      - id: type
        type: u1
        enum: node_type
      - id: count
        type: b24
      - id: entries
        type: hashmap64_entry
        repeat: expr
        repeat-expr: count
      - id: child_types
        type: u1
        enum: node_type
        repeat: expr
        repeat-expr: count

  string_table:
    doc: >
      Shared layout for the hash-key table, the value-string table, and
      (structurally) the path array: a type byte + 24-bit count, then
      count+1 u32 offsets (relative to this table's own start) bounding
      each entry.
    seq:
      - id: type
        type: u1
      - id: count
        type: b24
      - id: entry_offsets
        type: u4
        repeat: expr
        repeat-expr: count + 1
    instances:
      strings:
        value: entry_offsets
        doc: Resolve each entry by seeking to (table start + entry_offsets[i]) and reading a NUL-terminated string.

  path_point:
    doc: One point of a path/course: position, normal, and a game-defined value.
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
      - id: nx
        type: f4
      - id: ny
        type: f4
      - id: nz
        type: f4
      - id: val
        type: u4

  path_array:
    doc: >
      Same table shape as `string_table`, but each [start,end) byte range
      bounds a run of 28-byte `path_point`s instead of a string.
    seq:
      - id: type
        type: u1
      - id: count
        type: b24
      - id: entry_offsets
        type: u4
        repeat: expr
        repeat-expr: count + 1

enums:
  node_type:
    0x20: hashmap32
    0x21: hashmap64
    0x30: reloc_hashmap32
    0x31: reloc_hashmap64
    0xa0: string
    0xa1: binary
    0xa2: binary_aligned
    0xc0: array
    0xc1: map
    0xc2: string_table
    0xc3: path_array
    0xd0: bool
    0xd1: int_
    0xd2: float_
    0xd3: uint_
    0xd4: int64
    0xd5: uint64
    0xd6: double_
    0xff: null_
