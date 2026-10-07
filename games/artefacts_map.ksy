meta:
  id: artefacts_map
  title: Artefacts Studio .map level database (FAAFFAAF tagged-section stream)
  file-extension: map
  endian: be
doc: |
  Artefacts Studio ".map" level databases (Diabolik: The Original Sin, Boot
  Camp Academy, Jillian Michaels Fitness Ultimatum, Dodge Racing, Build-A-Bear
  Workshop, ... 30 audited retail Wii discs). The file uses the same
  `FAAFFAAF` tagged-section stream as the `.cfg` / `.gam` / `.loc` / `.ls` /
  `.rgn` files, but it holds the serialized engine object graph of a level:
  hierarchy nodes, skeletons (`Bip01 ...`), models and textures. Recovered
  from the game's own reader (`main.dol`) and checked against every `.map` of
  Boot Camp Academy.

  Stream layout (all big-endian):

      u4 0xFAAFFAAF, u4 8             file header (0xFBBFFBBF = byte-swapped twin)
      section:  u4 0xBBBBBBBB         begin tag (4-aligned)
                u4 end                file offset of the matching closing tag
                u4 version            per-class serialization version
                payload               raw fields and nested sections
                u4 0xBEBEBEBE         closing tag, located at `end`
      u4 0xFEEFFEEF                   end of file

  The whole file is one outermost section. Objects are polymorphic -- each is
  stored as a class id plus a section whose payload is that class'
  serialization routine's output -- so field meanings depend on the class.
  Children inside a payload start on 4-byte boundaries.

  Only two payload kinds are fully decoded, and they are provided as types you
  can apply to a leaf payload: `texture_leaf` and `mesh_leaf`.
seq:
  - id: magic
    contents: [0xfa, 0xaf, 0xfa, 0xaf]
  - id: header_word
    type: u4
    doc: Always 8.
  - id: root
    type: section
  - id: eof_tag
    contents: [0xfe, 0xef, 0xfe, 0xef]
types:
  section:
    seq:
      - id: begin_tag
        contents: [0xbb, 0xbb, 0xbb, 0xbb]
      - id: end
        type: u4
        doc: File offset of the closing tag.
      - id: version
        type: u4
        doc: Per-class serialization version.
      - id: payload
        size: end - _io.pos
        doc: Raw fields and nested (4-aligned) sections.
      - id: end_tag
        contents: [0xbe, 0xbe, 0xbe, 0xbe]
  texture_name:
    doc: |
      Name section payload of a texture object: `u4 length` (20) and 20 ASCII
      bytes.
    seq:
      - id: length
        type: u4
      - id: name
        type: strz
        size: length
        encoding: ASCII
  texture_record:
    doc: |
      The 8-byte record after the name section of a texture object.
    seq:
      - id: format
        type: u1
      - id: zero
        type: u1
      - id: one
        type: u1
      - id: width
        type: u2
      - id: height
        type: u2
      - id: zero2
        type: u1
  texture_leaf:
    doc: |
      Leaf payload holding the GX CMPR mip chain, tightly packed, largest level
      first (every one of the 304 textures in the 25 Boot Camp Academy maps has
      `width * height / 2` bytes per level, at least one 8x8 tile per level),
      followed by 3 bytes of padding.
    seq:
      - id: one
        type: u1
      - id: mip_count
        type: u4
      - id: byte_size
        type: u4
      - id: zero
        type: u4
      - id: mip_data
        size: byte_size
  mesh_leaf:
    doc: |
      Leaf payload `u1 1` followed by the arrays of one model, as read by the
      game. Positions are model-space, so the bind pose needs no skeleton
      (checked on Boot Camp Academy's drill sergeant: 1883 vertices, 3479
      triangles).
    seq:
      - id: one
        type: u1
      - id: num_vertices
        type: u4
      - id: vertices
        type: vertex
        repeat: expr
        repeat-expr: num_vertices
      - id: num_texcoords
        type: u4
      - id: texcoords
        type: texcoord
        repeat: expr
        repeat-expr: num_texcoords
      - id: num_positions2
        type: u4
      - id: positions2
        type: position2
        repeat: expr
        repeat-expr: num_positions2
        doc: Second position array (shadow / outline pass).
      - id: num_colors
        type: u4
      - id: colors
        size: 4
        repeat: expr
        repeat-expr: num_colors
        doc: Colour/tex array of that pass.
      - id: slots
        type: material_slot
        repeat: expr
        repeat-expr: 32
        doc: The 32 material slots.
  vertex:
    seq:
      - id: x
        type: s2
        doc: 4096 = 1.0, Z up.
      - id: y
        type: s2
      - id: z
        type: s2
      - id: bone0
        type: u1
      - id: bone1
        type: u1
      - id: nx
        type: s1
        doc: 64 = 1.0.
      - id: ny
        type: s1
      - id: nz
        type: s1
      - id: skin_u1
        type: u1
      - id: skin_extra
        size: 3
      - id: skin_weight
        type: u1
  texcoord:
    seq:
      - id: u
        type: u2
        doc: 1024 = 1.0.
      - id: v
        type: u2
  position2:
    seq:
      - id: x
        type: s2
      - id: y
        type: s2
      - id: z
        type: s2
  material_slot:
    seq:
      - id: num_skinned
        type: u1
      - id: skinned
        type: segment(true)
        repeat: expr
        repeat-expr: num_skinned
        doc: Entries that carry an extra 4 x u2 bone palette.
      - id: num_plain
        type: u1
      - id: plain
        type: segment(false)
        repeat: expr
        repeat-expr: num_plain
      - id: num_extra
        type: u1
      - id: extra
        type: extra_entry
        repeat: expr
        repeat-expr: num_extra
  segment:
    params:
      - id: has_palette
        type: bool
    seq:
      - id: first_vertex
        type: u2
        doc: Position / normal indices in the display list are relative to this.
      - id: vertex_count
        type: u2
      - id: triangles
        type: u4
      - id: unknown
        type: u2
      - id: display_list_size
        type: u4
      - id: display_list
        size: display_list_size
        doc: |
          GX commands (0x98 triangle strips; 0x00 NOP) whose vertices are
          `{u2 position, u2 normal, u2 texcoord}`; the texcoord index is global.
      - id: bone_palette
        size: 8
        if: has_palette
        doc: Four u2 bone indices.
  extra_entry:
    seq:
      - id: k
        type: u4
      - id: unknown
        type: u4
      - id: items
        size: 8
        repeat: expr
        repeat-expr: k
