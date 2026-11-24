meta:
  id: mh2_col
  title: Rockstar Leeds collision library (Manhunt 2)
  file-extension: col
  endian: be
doc: Names are NUL-terminated and padded with 'p' bytes to a 4-byte boundary.
seq:
  - id: entry_count
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: entry_count
types:
  vec3:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
  entry:
    seq:
      - id: name
        type: strz
        encoding: ASCII
      - id: name_pad
        size: (-(name.length + 1)) % 4
      - id: sphere_centre
        type: vec3
      - id: sphere_radius
        type: f4
      - id: box_min
        type: vec3
      - id: box_max
        type: vec3
      - id: sphere_count
        type: u4
      - id: spheres
        type: sphere
        repeat: expr
        repeat-expr: sphere_count
      - id: line_count
        type: u4
      - id: lines
        type: line
        repeat: expr
        repeat-expr: line_count
      - id: box_count
        type: u4
        doc: 0 on the Wii files.
      - id: vertex_count
        type: u4
      - id: vertices
        type: vec3
        repeat: expr
        repeat-expr: vertex_count
      - id: triangle_count
        type: u4
      - id: triangles
        type: triangle
        repeat: expr
        repeat-expr: triangle_count
  sphere:
    seq:
      - id: centre
        type: vec3
      - id: radius
        type: f4
      - id: surface
        size: 4
  line:
    seq:
      - id: a
        type: vec3
      - id: b
        type: vec3
  triangle:
    seq:
      - id: indices
        type: u4
        repeat: expr
        repeat-expr: 3
