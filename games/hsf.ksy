meta:
  id: hsf
  file-extension: hsf
  endian: be
  title: HAL Laboratory "HSFV037" model (Mario Party 4-8, Kirby Air Ride, Battalion Wars)
doc: |
  HAL Laboratory's tool-export model format (their "sysdolphin" GX runtime
  -- the same JObj/DObj/PObj/MObj/TObj object model documented in the
  public Kirby Air Ride decompilation, doldecomp/kar). Shipped as .hsf by
  Mario Party 4-8 and extracted from Mario Party's MPBIN container by
  wmpbdump; the same tool family also appears in Kirby Air Ride, Battalion
  Wars and other GameCube/Wii titles. Independently cross-checked against
  Hudson's GPL `hsfview` runtime sources and Nokonoko Estate's parser, on
  top of real retail Mario Party 4 data (board pieces and characters).

  A fixed 20-entry top-level table of { offset, count } pairs starts right
  after the "HSFV037" magic; most entries point at an array of `count`
  12-byte AttributeHeader records { name_str_off, data_count, data_off
  (relative to the end of that header array) } -- one per named mesh part
  for the geometry-bearing entries (positions, normals, uvs, faces). A
  `count > 1` AttributeHeader array is not N repeated raw data blocks; it
  is N independently-named mesh parts, addressed indirectly through their
  own per-part headers rather than sizes in the top table -- this is what
  a real multi-part or skinned character model's positions/faces sections
  look like, and getting this wrong makes every such model (as opposed to
  the simpler count==1 case) look unsupported.

  Face records are `s16 type; s16 material&0xff` followed by per-vertex
  {position,normal,color,uv} index groups: type 2 is a triangle (one
  VertexGroup[3]), type 3 a quad (VertexGroup[4], split into triangles
  0-1-2 and 1-3-2), and type 4 an indexed triangle-strip/fan (VertexGroup[3]
  plus an extra-vertex count and an offset into a shared pool right after
  all primitive-table data) -- confirmed against real skinned character
  and board-piece meshes, not merely hypothesized from the reference
  reader. Any other type aborts decoding rather than guessing further.
  Normals have two on-disk variants: the common 3x big-endian f32 XYZ, or,
  in some real sections, 3 signed bytes (value/127.0) 0x20-byte aligned --
  detected by whether a second per-mesh normal header's data_off lines up
  with the first header's byte-packed (rather than float) end.

  Beyond the AttributeHeader layer, section contents are algorithmic and
  version-dependent (see the long verification comment above `DecodeHSF`
  in lib-hsf.c) and are not modeled further here. For reference, sizes
  confirmed against real files and the loader's own field accesses: node
  (`HSF_IDX_NODES`) records are 0x144 bytes each (type at +4, parent index
  at +16 for non-replica types, name-string offset at +0, a replica's
  target node index at +0x64); cluster (`HSF_IDX_CLUSTERS`) records are
  0xA0 bytes (name/target/coord-target string offsets, owning part index,
  weight-source metadata at +0x94..+0x9F); part (`HSF_IDX_PARTS`) and
  shape (`HSF_IDX_SHAPES`) records are 12 bytes each; a motion
  (`HSF_IDX_MOTIONS`) track header is 16 bytes, followed by per-target
  animation tracks and keyframe data. `HSF_IDX_SYMBOLS` (index 19) is the
  string pool every `name_str_off`/`ofs_name` field above indexes into.
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
    # 13 is deliberately absent: no known real file populates it, and the
    # decoder's own HSF_IDX_* table (lib-hsf.c) skips straight from 12 to
    # 14 -- an unused directory slot, not a modeling gap.
    14: parts
    15: clusters
    16: shapes
    17: map_attr
    18: matrices
    19: symbols
types:
  top_entry:
    doc: |
      One directory slot. `positions`/`normals`/`uvs`/`faces` point at an
      `attribute_header` array (one entry per named mesh part); `nodes`,
      `clusters`, `parts`, `shapes`, `motions`, `scene` and `map_attr`
      point directly at fixed-size record arrays instead (see the format
      `doc` above for their sizes) -- `count` there is the record count,
      not an AttributeHeader count, so `attribute_headers` below only
      makes structural sense for the AttributeHeader-shaped entries.
    seq:
      - id: ofs_body
        type: u4
        doc: File offset of this entry's body; 0 when the section is absent (e.g. `envelopes` on an unskinned model).
      - id: count
        type: u4
        doc: Number of records in this entry's body -- an `attribute_header` count for the geometry entries, a plain record count otherwise.
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
      whole AttributeHeader array this record belongs to. A single-part
      model still has a length-1 array here -- there is no separate
      "no sub-parts" layout, which is why the effective byte layout for
      `count == 1` happens to match what an older, simpler reader assumed
      was a fixed sub-header.
    seq:
      - id: ofs_name
        type: u4
        doc: Offset into the file's string table (HSF_IDX_SYMBOLS section) of this part's name.
      - id: data_count
        type: u4
        doc: |
          Number of attribute records for this part. For `faces`, each
          record's own `s16 type` further selects triangle (2), quad (3)
          or indexed triangle-strip (4) layout -- `data_count` alone does
          not give the byte size of a `faces` part.
      - id: ofs_data
        type: u4
        doc: Byte offset of this part's data, relative to the end of the owning AttributeHeader array.
