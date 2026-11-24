meta:
  id: zeldabake
  title: Switch 2 Zelda baked light list (.bklight)
  file-extension: bklight
  endian: le
doc: |
  "BKLT", u32 version 1, u32 counts of point / spot / area lights, then three
  arrays (f32 LE). Point (28 B): position[3], color[3], scale. Spot (52):
  position[3], direction[3], color[3], falloff[2], intensity, scale. Area (60):
  position[3], direction[3], up[3], color[3], size[2], intensity.
  Related tables (separate files): .bbox culling boxes {u32 version 2, u32 count,
  count x 44 bytes {u32 id, u32 flags, center[3], reserved[3], size[3]}}; .flnt
  impostor info {u32 version 2, 0, N names, R records, N x 256-byte pascal
  strings, N x {u32 first record, count, kind, 0}, R x 80-byte records}; MCPK
  mesh codec package {"MCPK", u8 micro, u8 minor, u16 major, u32 flags, u32 size
  A, X, size B, 0x803, section A ("FMSH"...), section B}.
seq:
  - id: magic
    contents: BKLT
  - id: version
    type: u4
  - id: point_count
    type: u4
  - id: spot_count
    type: u4
  - id: area_count
    type: u4
  - id: points
    type: point
    repeat: expr
    repeat-expr: point_count
  - id: spots
    type: spot
    repeat: expr
    repeat-expr: spot_count
  - id: areas
    type: area
    repeat: expr
    repeat-expr: area_count
types:
  vec3:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
  point:
    seq:
      - id: position
        type: vec3
      - id: color
        type: vec3
      - id: scale
        type: f4
  spot:
    seq:
      - id: position
        type: vec3
      - id: direction
        type: vec3
      - id: color
        type: vec3
      - id: falloff
        type: f4
        repeat: expr
        repeat-expr: 2
      - id: intensity
        type: f4
      - id: scale
        type: f4
  area:
    seq:
      - id: position
        type: vec3
      - id: direction
        type: vec3
      - id: up
        type: vec3
      - id: color
        type: vec3
      - id: size
        type: f4
        repeat: expr
        repeat-expr: 2
      - id: intensity
        type: f4
