meta:
  id: rainbow_gct
  endian: be
  title: Rainbow Studios GCT texture (Disney-Pixar Cars, GameCube/Wii)
doc: |
  Rainbow Studios engine ".gct" texture, recovered from the game's
  unstripped ELF (GCNTextureMap::LoadFromContainer) per lib-rainbow.h.
  Format 58 (CI8) carries a 256-entry RGB5A3 palette; format 41 is
  CMPR with no palette. Surfaces are stored smallest-mip-first, each
  as GX-tiled raw data (not detiled here).
seq:
  - id: unknown_flags
    type: u4
    doc: Always 2 in observed files.
  - id: format
    type: u4
    doc: 58 = CI8 (indexed, palette follows), 41 = CMPR.
  - id: palette_count
    type: u4
  - id: palette
    type: u2
    repeat: expr
    repeat-expr: 'format == 58 ? palette_count : 0'
    doc: RGB5A3 entries, present only for format 58 (CI8).
  - id: surface_count
    type: u4
  - id: width
    type: u4
  - id: height
    type: u4
  - id: surfaces
    type: surface
    repeat: expr
    repeat-expr: surface_count
    doc: Stored smallest mip to largest.
types:
  surface:
    seq:
      - id: width
        type: u4
      - id: height
        type: u4
      - id: data_size
        type: u4
      - id: data
        size: data_size
        doc: Raw GX-tiled data, not detiled here.
