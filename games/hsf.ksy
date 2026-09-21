meta:
  id: hsf
  file-extension: hsf
  endian: be
  title: HAL Laboratory "HSFV037" model (Mario Party 4-8, Kirby Air Ride, Battalion Wars)
doc: |
  HAL Laboratory's tool-export model format (their "sysdolphin" GX runtime).
  A fixed 20-entry top-level table of { offset, count } pairs starts right
  after the "HSFV037" magic; most entries point at an array of `count`
  12-byte AttributeHeader records { name_str_off, data_count, data_off
  (relative to the end of that header array) } -- one per named mesh part
  for the geometry-bearing entries. Section contents (geometry, materials,
  object hierarchy, textures, motions, ...) beyond the AttributeHeader
  layer are algorithmic/version-dependent (see the long verification
  comment above `DecodeHSF` in lib-hsf.c) and are not modeled further here.
seq:
  - id: magic
    contents: "HSFV037"
  - id: pad
    size: 1
  - id: entries
    type: top_entry
    repeat: expr
    repeat-expr: 20
enums:
  top_index:
    0: scene
    1: colors
    2: materials
    3: attributes
    4: positions
    5: normals
    6: uvs
    7: faces
    8: nodes
    9: textures
    10: palettes
    11: motions
    12: envelopes
    14: parts
    15: clusters
    16: shapes
    17: map_attr
    18: matrices
    19: symbols
types:
  top_entry:
    seq:
      - id: ofs_body
        type: u4
      - id: count
        type: u4
    instances:
      attribute_headers:
        io: _root._io
        pos: ofs_body
        type: attribute_header
        repeat: expr
        repeat-expr: count
        if: ofs_body != 0 and count > 0
  attribute_header:
    doc: |
      One named mesh part's sub-table: `data_count` records of this
      attribute's data, starting `data_off` bytes after the end of the
      whole AttributeHeader array this record belongs to.
    seq:
      - id: ofs_name
        type: u4
        doc: Offset into the file's string table (HSF_IDX_SYMBOLS section) of this part's name.
      - id: data_count
        type: u4
      - id: ofs_data
        type: u4
        doc: Byte offset of this part's data, relative to the end of the owning AttributeHeader array.
