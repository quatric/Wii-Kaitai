meta:
  id: csb
  file-extension: csb
  endian: le
  title: Paper Mario collision scene (Switch, little-endian)
doc: |
  Collision scene binary shared by Paper Mario: The Thousand-Year Door
  (Switch remake) and Paper Mario: The Origami King (Switch); Paper Mario:
  Color Splash (Wii U) stores the same fields big-endian with a couple of
  width changes (`colflag` as `u32` instead of `u64`, and no `unknown4`
  padding word in the per-model header) and is not modeled by this
  little-endian spec.

  There is no magic anywhere in the file -- Wiimms Tools (`lib-csb.c`)
  identifies and disambiguates endianness purely by walking the whole
  structure and checking that every count and offset lands exactly on
  the next field, all the way to EOF. This spec only re-expresses the
  little-endian layout that walk recovers; retail files are normally
  Zstandard-compressed as `.csb.zst` and must be decompressed first.

  Re-derived in C from KillzXGaming/CollisionSceneBinary (MIT, 2024); no
  upstream code is copied, only the layout it documents.
seq:
  - id: num_spheres
    type: u4
  - id: spheres
    type: sphere
    repeat: expr
    repeat-expr: num_spheres
  - id: num_boxes
    type: u4
  - id: boxes
    type: box
    repeat: expr
    repeat-expr: num_boxes
  - id: zero0
    type: u4
    doc: Always 0.
  - id: one0
    type: u4
    doc: Always 1.
  - id: pad0
    size: 16
    doc: Always zero.
  - id: num_objects
    type: u4
    doc: |
      Total sphere+box trigger volume count; drives the object name/flag/
      node tables that follow (not modeled here as they are addressed by
      a shared string table read separately -- see `lib-csb.c`).
types:
  vec3:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
  sphere:
    doc: A trigger volume; `p1` and `p2` are identical for a sphere.
    seq:
      - id: unknown
        type: f4
        doc: Always 0.
      - id: p1
        type: vec3
      - id: p2
        type: vec3
      - id: radius
        type: f4
  box:
    doc: A box trigger volume.
    seq:
      - id: unknown
        type: f4
        doc: Always 0.
      - id: p1
        type: vec3
      - id: p2
        type: vec3
      - id: size
        type: vec3
        doc: Box scale.
      - id: rotation
        type: vec3
        doc: Euler rotation, degrees.
      - id: box_extra
        type: f4
        repeat: expr
        repeat-expr: 9
        doc: A fixed 3x3-matrix-shaped block, always {0,0,1, 0,0,0, 0,1,0}.
