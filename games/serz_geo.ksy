meta:
  id: serz_geo
  title: Ubisoft/Kuju SERZ geometry (.GeoWii)
  file-extension: geowii
  endian: le
doc: |
  Same token stream as serz_tg plus {0xff 'R', name, u32} and {0xff 'A', name,
  type, u8 count, values}; 'p' and 'R' tokens also take an entity number
  (entities are 0-based in compact references; a compact 'p' carries no
  payload). One cHcPrimitiveSetDescWii holds a big-endian vertex-array blob
  (array 0 positions 3 x f32, array 1 normals 3 x f32 or colours 4 bytes,
  then texcoords 2 x f32) at ArrayOffset/ArraySize and a GX display list blob
  (0x80 quads, 0x90 triangles, 0x98 strip, 0xA0 fan, u16 vertex count, then one
  big-endian u16 index per array column, 3-5 columns).
seq:
  - id: magic
    contents: SERZ
  - id: version
    type: u4
  - id: stream
    size-eos: true
    doc: |
      The token stream is the one described by `serz_tokens`, extended with 'R'
      and 'A' tokens; those need the entity table, so decode it application side
      and use the blob types below on the extracted blobs.
types:
  display_list:
    doc: |
      GX display list blob of one primitive set. `columns` (3-5) is the number
      of big-endian u16 indices per vertex, one per vertex-array column; the
      extractor derives it as the vertex size (6-20 bytes, step 2) that tiles the
      list exactly. Ends at a zero opcode (the rest is zero padding).
    params:
      - id: columns
        type: s4
    seq:
      - id: commands
        type: display_list_cmd(columns)
        repeat: until
        repeat-until: _.opcode == 0 or _io.eof
  display_list_cmd:
    params:
      - id: columns
        type: s4
    seq:
      - id: opcode
        type: u1
        doc: 0x80 quads, 0x90 triangles, 0x98 strip, 0xA0 fan (0xA8 / 0xB0 are also accepted by the extractor).
      - id: vertex_count
        type: u2be
        if: opcode != 0
      - id: vertices
        type: vertex(columns)
        repeat: expr
        repeat-expr: vertex_count
        if: opcode != 0
  vertex:
    params:
      - id: columns
        type: s4
    seq:
      - id: indices
        type: u2be
        repeat: expr
        repeat-expr: columns
  vertex_array_blob:
    doc: |
      Big-endian vertex-array blob at ArrayOffset/ArraySize. Array 0 holds
      positions (3 x f32), array 1 normals (3 x f32, when its size equals the
      positions') or 4-byte colours, then 2 x f32 texcoords. Sizes come from the
      primitive set's ArraySize entries; the element counts are size / 12 (and
      / 8 for texcoords, / 4 for colours).
    params:
      - id: position_bytes
        type: s4
    seq:
      - id: positions
        type: position
        repeat: expr
        repeat-expr: position_bytes / 12
      - id: rest
        size-eos: true
  position:
    seq:
      - id: x
        type: f4be
      - id: y
        type: f4be
      - id: z
        type: f4be
