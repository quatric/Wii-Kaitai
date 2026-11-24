meta:
  id: unityassets
  title: Unity 2.x Wii SerializedFile (version 6, big endian)
  file-extension: assets
  endian: be
doc: |
  `sharedassets*.assets`, `levelN`, `mainData`. Metadata sits at
  `file_size - metadata_size`. class 28 Texture2D: name (u32 len, padded to 4)
  + BE words {0, 1, 2, width, height, image_size, format << 16, data_size,
  lz_size} + LZ11 stream (formats 0x10 IA8, 0x11 RGB565, 0x12 RGB5A3,
  0x13 RGBA8, 0x14 CMPR; rows bottom-up). class 83 AudioClip: name, float
  length, 4 words, chunk size, two 0x60-byte DSP headers each followed by one
  channel. class 49 TextAsset: name + u32 length + bytes. Later builds store
  type trees (type_count > 0).
seq:
  - id: metadata_size
    type: u4
  - id: file_size
    type: u4
  - id: version
    type: u4
    doc: 6.
  - id: data_offset
    type: u4
    doc: 0.
instances:
  metadata:
    pos: file_size - metadata_size
    type: metadata
types:
  metadata:
    seq:
      - id: endian
        type: u1
        doc: 1 = big endian.
      - id: type_count
        type: s4
      - id: types
        type: type_entry
        repeat: expr
        repeat-expr: type_count
      - id: object_count
        type: s4
      - id: objects
        type: object
        repeat: expr
        repeat-expr: object_count
  type_entry:
    seq:
      - id: class_id
        type: s4
      - id: root
        type: node
  node:
    seq:
      - id: type_name
        type: strz
        encoding: ASCII
      - id: name
        type: strz
        encoding: ASCII
      - id: size
        type: s4
      - id: index
        type: s4
      - id: is_array
        type: s4
      - id: version
        type: s4
      - id: flags
        type: s4
      - id: child_count
        type: s4
      - id: children
        type: node
        repeat: expr
        repeat-expr: child_count
  object:
    seq:
      - id: path_id
        type: s4
      - id: byte_start
        type: u4
      - id: byte_size
        type: u4
      - id: type_id
        type: s4
      - id: class_id
        type: u2
      - id: destroyed
        type: u2
    instances:
      data:
        pos: _root.data_offset + byte_start
        size: byte_size
        io: _root._io
  texture2d:
    doc: Class 28; the LZ11 stream holds the first mip level plus the chain.
    seq:
      - id: name_len
        type: u4
      - id: name
        size: name_len
        type: str
        encoding: ASCII
      - id: name_pad
        size: (-name_len) % 4
      - id: zero
        type: u4
      - id: one
        type: u4
      - id: two
        type: u4
      - id: width
        type: u4
      - id: height
        type: u4
      - id: image_size
        type: u4
      - id: format_shifted
        type: u4
        doc: format << 16; 0x10 IA8, 0x11 RGB565, 0x12 RGB5A3, 0x13 RGBA8, 0x14 CMPR.
      - id: data_size
        type: u4
      - id: lz_size
        type: u4
      - id: lz11
        size: lz_size
  text_asset:
    doc: Class 49.
    seq:
      - id: name_len
        type: u4
      - id: name
        size: name_len
        type: str
        encoding: ASCII
      - id: name_pad
        size: (-name_len) % 4
      - id: length
        type: u4
      - id: data
        size: length
