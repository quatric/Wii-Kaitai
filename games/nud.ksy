meta:
  id: nud
  file-extension: nud
  endian: be
  title: Namco NUD model (Super Smash Bros. Brawl / Pokkén)
doc: |
  NUD model container used by several Namco-developed titles (Super Smash
  Bros. Brawl and derivatives, Pokkén Tournament). Ported from
  `lib-nud.c`/`.h`. The magic selects endianness: "NDP3"/"NDWU" are
  big-endian (GC/Wii), "NDWD" is little-endian; this definition models the
  big-endian ("NDP3") layout, byte-for-byte mirrored for the little-endian
  variants.

  Only the "full" Smash 4 / Pokkén layout (fixed 48-byte object records
  followed by 48-byte polygon descriptors) is modelled here; lib-nud.c
  also has a legacy flat/simple fallback layout for older or synthetic
  files that this definition does not cover.
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
    valid:
      any-of: ['"NDP3"', '"NDWU"', '"NDWD"']
  - id: version
    type: u2
  - id: polysets
    type: u2
    doc: Number of mesh objects.
  - id: unk1
    size: 4
  - id: poly_clump_rel
    type: s4
    doc: Relative to the end of the 0x30-byte header.
  - id: poly_clump_sz
    type: s4
  - id: vert_clump_sz
    type: s4
  - id: vertadd_clump_sz
    type: s4
  - id: bounding_sphere_center
    size: 12
  - id: bounding_sphere_radius
    type: f4
  - id: objects
    type: object
    repeat: expr
    repeat-expr: polysets
types:
  object:
    doc: 48 bytes.
    seq:
      - id: unk1
        size: 32
      - id: name_rel
        type: s4
        doc: Relative to the start of the object name table.
      - id: unk2
        size: 6
      - id: poly_count
        type: u2
        doc: Number of polygon descriptors (sub-polygons) for this object.
  polygon_descriptor:
    doc: 48 bytes.
    seq:
      - id: poly_start_rel
        type: s4
      - id: vert_start_rel
        type: s4
      - id: vertadd_start_rel
        type: s4
      - id: vcount
        type: u2
      - id: vert_size
        type: u1
        doc: High nibble bone_type, low nibble vertex_type.
      - id: uv_size
        type: u1
        doc: High nibble uv_count, low nibble uv_type.
      - id: unk1
        size: 16
      - id: pcount
        type: u2
      - id: poly_size
        type: u1
        doc: Index element size selector (4 = u8 indices, else u16).
      - id: poly_flag
        type: u1
        doc: 4 = triangle list, else triangle strip.
      - id: unk2
        size: 12
