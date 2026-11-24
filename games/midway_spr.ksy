meta:
  id: midway_spr
  title: Midway sprite set (.spr)
  file-extension: spr
  endian: be
doc: |
  Midway sprite set (members of TNA Impact! `.WAD` packs). A sprite record is 36
  bytes: a pad word then four `{u, v}` float corners (normalised coordinates into
  the named `.tim` atlas, order (u0,v0) (u1,v0) (u1,v1) (u0,v1)). Geometry
  trailing the last record is ignored.
seq:
  - id: reserved0
    size: 0x0c
  - id: len_data
    type: u4
  - id: num_names
    type: u4
  - id: name_table_offset
    type: u4
    doc: 20-byte names.
  - id: num_sprites
    type: u4
  - id: sprite_offsets
    type: u4
    repeat: expr
    repeat-expr: num_sprites
types:
  sprite:
    seq:
      - id: pad
        type: u4
      - id: corners
        type: f4
        repeat: expr
        repeat-expr: 8
