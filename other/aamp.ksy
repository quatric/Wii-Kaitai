meta:
  id: aamp
  file-extension: aamp
  title: Nintendo AAMP parameter archive
doc: |
  Nintendo EAD's "Parameter IO" binary archive: a tree of named parameter
  lists, each holding child lists, objects, and (inside an object) typed
  parameter entries. Two on-disk generations exist, told apart by the
  version field right after the magic: V1 (Wii U and earlier) is a plain
  self-sized tree -- every list/object/entry starts with its own total
  byte size, so a reader can skip what it doesn't understand -- while V2
  (Switch-era) is a fixed-size-node graph addressed by *4-scaled offsets
  relative to each node's own start (a "BFS"-shaped index into a shared
  data/string pool), which is how this .ksy models it: as instances
  computed from a node's own absolute offset, not a plain seq.

  Endianness is picked up from the version field itself: this tool reads
  it once as little-endian, and if that yields 1 or 2 assumes the whole
  file is little-endian, otherwise big-endian.
seq:
  - id: magic
    contents: "AAMP"
  - id: version_le_probe
    type: u4le
    doc: Read little-endian first to detect overall endianness; 1 or 2 means the file is little-endian.
  - id: body
    type:
      switch-on: is_le
      cases:
        true: header(true)
        false: header(false)
instances:
  is_le:
    value: version_le_probe == 1 or version_le_probe == 2
  version:
    value: version_le_probe
types:
  header:
    doc: |
      Starts right after the already-consumed `magic` + version field
      (absolute offset 8); the version value itself is `_root.version`.
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
      - id: flags
        type: u4
      - id: len_file
        type: u4
      - id: pio_version
        type: u4
      - id: v2_ofs_root
        type: u4
        if: _root.version == 2
        doc: |
          V2 only: byte offset of the root list, relative to absolute
          offset 0x30; see `root_v2`.
      - id: v2_reserved
        size: 0x30 - 24
        if: _root.version == 2
      - id: v1_len_pio_type
        type: u4
        if: _root.version == 1
      - id: v1_pio_type
        type: str
        encoding: ASCII
        size: v1_len_pio_type
        if: _root.version == 1
      - id: v1_pad
        size: (4 - v1_len_pio_type % 4) % 4
        if: _root.version == 1
    instances:
      pio_type_v2:
        pos: 0x30
        io: _root._io
        type: strz
        encoding: ASCII
        if: _root.version == 2
      root_v1:
        type: list_v1
        if: _root.version == 1
      root_v2:
        io: _root._io
        pos: 0x30 + v2_ofs_root
        type: list_v2(0x30 + v2_ofs_root)
        if: _root.version == 2

  # ---- V1: plain self-sized tree ----
  list_v1:
    seq:
      - id: len_node
        type: u4
      - id: hash
        type: u4
      - id: num_lists
        type: u4
      - id: num_objects
        type: u4
      - id: lists
        type: list_v1
        repeat: expr
        repeat-expr: num_lists
      - id: objects
        type: object_v1
        repeat: expr
        repeat-expr: num_objects
  object_v1:
    seq:
      - id: len_node
        type: u4
      - id: num_entries
        type: u4
      - id: hash
        type: u4
      - id: group_hash
        type: u4
      - id: entries
        type: entry_v1
        repeat: expr
        repeat-expr: num_entries
  entry_v1:
    seq:
      - id: len_node
        type: u4
      - id: param_type
        type: u4
        enum: param_type
      - id: hash
        type: u4
      - id: payload
        size: len_node - 12
        doc: Type-dependent scalar/vector/string/buffer/curve payload; see `param_type`.

  # ---- V2: fixed-size nodes, *4-scaled offsets relative to the node's own start ----
  list_v2:
    params:
      - id: start
        type: u4
    seq:
      - id: hash
        type: u4
      - id: ofs_lists
        type: u2
      - id: num_lists
        type: u2
      - id: ofs_objects
        type: u2
      - id: num_objects
        type: u2
    instances:
      lists:
        io: _root._io
        pos: start + ofs_lists * 4
        type: list_v2(start + ofs_lists * 4 + _index * 12)
        repeat: expr
        repeat-expr: num_lists
        if: num_lists > 0 and ofs_lists > 0
      objects:
        io: _root._io
        pos: start + ofs_objects * 4
        type: object_v2(start + ofs_objects * 4 + _index * 8)
        repeat: expr
        repeat-expr: num_objects
        if: num_objects > 0 and ofs_objects > 0
  object_v2:
    params:
      - id: start
        type: u4
    seq:
      - id: hash
        type: u4
      - id: ofs_entries
        type: u2
      - id: num_entries
        type: u2
    instances:
      entries:
        io: _root._io
        pos: start + ofs_entries * 4
        type: entry_v2(start + ofs_entries * 4 + _index * 8)
        repeat: expr
        repeat-expr: num_entries
        if: num_entries > 0 and ofs_entries > 0
  entry_v2:
    params:
      - id: start
        type: u4
    seq:
      - id: hash
        type: u4
      - id: packed
        type: u4
        doc: Bits 0-23 data offset (*4-scaled, relative to `start`); bits 24-31 param type.
    instances:
      data_offset:
        value: packed & 0x00ffffff
      param_type:
        value: (packed >> 24) & 0xff
        enum: param_type
      abs_data_offset:
        value: start + data_offset * 4
      # AAMP_TYPE_BUFFER_INT/UINT/FLOAT/BIN store a u32 element count right
      # before `abs_data_offset`; not modeled further here since the
      # element type/size depends on `param_type`.
enums:
  param_type:
    0: bool_t
    1: float_t
    2: int_t
    3: vec2
    4: vec3
    5: vec4
    6: color
    7: string32
    8: string64
    9: curve1
    10: curve2
    11: curve3
    12: curve4
    13: buffer_int
    14: buffer_float
    15: string256
    16: quat
    17: uint_t
    18: buffer_uint
    19: buffer_bin
    20: string_ref
