meta:
  id: smashlvd
  endian: be
  title: Super Smash Bros. 4 stage/level data (LVD)
doc: |
  Super Smash Bros. 4 stage/level data (.lvd), per lib-smashlvd.c
  (ported from KillzXGaming/Smash-Forge LVD.cs). The fixed ten-byte
  header is followed without alignment by 19 lists in a fixed order.
  Each list begins with byte 0x01 and a big-endian signed count. Lists
  1..6 contain collisions, spawns, respawns, camera bounds, blast zones,
  and enemy generators. Lists 7..11 are reserved and must be empty.
  Lists 12..15 contain damage shapes, item spawners, general shapes,
  and general points. Lists 16..19 must also be empty.

  Every nonempty record starts with a 12-byte family identity, followed
  by 223 shared tagged bytes: fixed-width name, subname, start point,
  control values, and bone name. The reference decoder collects nonzero
  bytes from each fixed-width string field rather than stopping at the
  first NUL; this schema leaves those fields raw to avoid changing that
  behavior. Collision-family, spawn-family, and item-family records have
  different identity bytes. Subsequent fields are tag-prefixed where
  shown below. The one-byte shape type tag is skipped without checking
  its value; all other modeled field tags are required to be 0x01.

  nintoolbox rejects negative or excessive counts, unknown damage shape
  types, malformed identity constants, truncated fields, nonempty
  reserved lists, and any trailing bytes after the nineteenth list.
  It reports some control bytes and floats without assigning further
  semantics. This schema exposes those bytes, but does not enforce every
  count limit or the EOF-equality check.
seq:
  - id: unknown_magic
    contents: [0x00, 0x00, 0x00, 0x01]
    doc: Fixed big-endian leading value 1.
  - id: unknown_04
    contents: [0x0a]
    doc: Fixed header byte 0x0a.
  - id: unknown_05
    contents: [0x01]
    doc: Fixed header byte 0x01.
  - id: magic
    contents: "LVD1"
    doc: ASCII format signature.
  - id: collisions_header
    type: list_prefix
  - id: collisions
    type: collision_entry
    repeat: expr
    repeat-expr: collisions_header.count
  - id: spawns_header
    type: list_prefix
  - id: spawns
    type: spawn_entry
    repeat: expr
    repeat-expr: spawns_header.count
  - id: respawns_header
    type: list_prefix
  - id: respawns
    type: spawn_entry
    repeat: expr
    repeat-expr: respawns_header.count
  - id: camera_bounds_header
    type: list_prefix
  - id: camera_bounds
    type: bounds_entry
    repeat: expr
    repeat-expr: camera_bounds_header.count
  - id: blast_zones_header
    type: list_prefix
  - id: blast_zones
    type: bounds_entry
    repeat: expr
    repeat-expr: blast_zones_header.count
  - id: enemies_header
    type: list_prefix
  - id: enemies
    type: enemy_entry
    repeat: expr
    repeat-expr: enemies_header.count
  - id: reserved_6
    type: empty_list
  - id: reserved_7
    type: empty_list
  - id: reserved_8
    type: empty_list
  - id: reserved_9
    type: empty_list
  - id: reserved_10
    type: empty_list
  - id: damage_shapes_header
    type: list_prefix
  - id: damage_shapes
    type: damage_entry
    repeat: expr
    repeat-expr: damage_shapes_header.count
  - id: item_spawners_header
    type: list_prefix
  - id: item_spawners
    type: item_entry
    repeat: expr
    repeat-expr: item_spawners_header.count
  - id: general_shapes_header
    type: list_prefix
  - id: general_shapes
    type: general_shape_entry
    repeat: expr
    repeat-expr: general_shapes_header.count
  - id: general_points_header
    type: list_prefix
  - id: general_points
    type: general_point_entry
    repeat: expr
    repeat-expr: general_points_header.count
  - id: reserved_15
    type: empty_list
  - id: reserved_16
    type: empty_list
  - id: reserved_17
    type: empty_list
  - id: reserved_18
    type: empty_list
types:
  list_prefix:
    seq:
      - id: tag
        contents: [0x01]
      - id: count
        type: s4
        doc: Number of entries in this list; decoder accepts 0..100000.
  empty_list:
    seq:
      - id: tag
        contents: [0x01]
      - id: count
        type: s4
        valid:
          eq: 0
        doc: Reserved list count must be zero.
  tagged_s32:
    seq:
      - id: tag
        contents: [0x01]
      - id: value
        type: s4
  tagged_zero:
    seq:
      - id: tag
        contents: [0x01]
      - id: value
        type: s4
        valid:
          eq: 0
  tagged_vec2:
    seq:
      - id: tag
        contents: [0x01]
      - id: x
        type: f4
      - id: y
        type: f4
  shared_base:
    doc: 223 tagged bytes shared by all nonempty record families.
    seq:
      - id: name_tag
        contents: [0x01]
      - id: name_bytes
        size: 0x38
      - id: subname_tag
        contents: [0x01]
      - id: subname_bytes
        size: 0x40
      - id: start_tag
        contents: [0x01]
      - id: start_x
        type: f4
      - id: start_y
        type: f4
      - id: start_z
        type: f4
      - id: use_start_point
        type: u1
      - id: unknown1_tag
        contents: [0x01]
      - id: unknown1
        type: s4
      - id: unknown2_tag
        contents: [0x01]
      - id: unknown2_x
        type: f4
      - id: unknown2_y
        type: f4
      - id: unknown2_z
        type: f4
      - id: unknown3
        type: s4
      - id: bone_tag
        contents: [0x01]
      - id: bone_bytes
        size: 0x40
  collision_entry:
    seq:
      - id: identity
        contents: [0x03, 0x04, 0x01, 0x01, 0x77, 0x35, 0xbb, 0x75, 0, 0, 0, 2]
      - id: base
        type: shared_base
      - id: flags
        size: 4
      - id: vertex_count
        type: tagged_s32
      - id: vertices
        type: tagged_vec2
        repeat: expr
        repeat-expr: vertex_count.value
      - id: normal_count
        type: tagged_s32
      - id: normals
        type: tagged_vec2
        repeat: expr
        repeat-expr: normal_count.value
      - id: cliff_count
        type: tagged_s32
      - id: cliffs
        type: cliff_entry
        repeat: expr
        repeat-expr: cliff_count.value
      - id: material_count
        type: tagged_s32
      - id: materials
        type: collision_material
        repeat: expr
        repeat-expr: material_count.value
  cliff_entry:
    seq:
      - id: identity
        contents: [0x03, 0x04, 0x01, 0x01, 0x77, 0x35, 0xbb, 0x75, 0, 0, 0, 2]
      - id: base
        type: shared_base
      - id: position_tag
        contents: [0x01]
      - id: x
        type: f4
      - id: y
        type: f4
      - id: angle
        type: f4
      - id: line
        type: s4
  collision_material:
    seq:
      - id: tag
        contents: [0x01]
      - id: raw
        size: 12
        doc: Physics byte is raw[3]; flags byte is raw[10].
  spawn_entry:
    seq:
      - id: identity
        contents: [0x02, 0x04, 0x01, 0x01, 0x77, 0x35, 0xbb, 0x75, 0, 0, 0, 2]
      - id: base
        type: shared_base
      - id: position
        type: tagged_vec2
  bounds_entry:
    seq:
      - id: identity
        contents: [0x02, 0x04, 0x01, 0x01, 0x77, 0x35, 0xbb, 0x75, 0, 0, 0, 2]
      - id: base
        type: shared_base
      - id: bounds_tag
        contents: [0x01]
      - id: left
        type: f4
      - id: right
        type: f4
      - id: top
        type: f4
      - id: bottom
        type: f4
  shape:
    seq:
      - id: type_tag
        type: u1
        doc: Usually 0x03 on save; decoder skips it without validation.
      - id: kind
        type: s4
      - id: x1
        type: f4
      - id: y1
        type: f4
      - id: x2
        type: f4
      - id: y2
        type: f4
      - id: count_tag1
        contents: [0x01]
      - id: count_tag2
        contents: [0x01]
      - id: point_count
        type: s4
      - id: points
        type: tagged_vec2
        repeat: expr
        repeat-expr: point_count
  shape_section:
    seq:
      - id: tag
        contents: [0x01]
      - id: data
        type: shape
  shape_list:
    seq:
      - id: tag1
        contents: [0x01]
      - id: tag2
        contents: [0x01]
      - id: count
        type: s4
      - id: sections
        type: shape_section
        repeat: expr
        repeat-expr: count
  enemy_entry:
    seq:
      - id: identity
        contents: [0x03, 0x04, 0x01, 0x01, 0x77, 0x35, 0xbb, 0x75, 0, 0, 0, 2]
      - id: base
        type: shared_base
      - id: sections1
        type: shape_list
      - id: sections2
        type: shape_list
      - id: empty1_tag1
        contents: [0x01]
      - id: empty1_tag2
        contents: [0x01]
      - id: empty1_count
        type: s4
        valid:
          eq: 0
      - id: id
        type: tagged_s32
      - id: sub_id_count
        type: tagged_s32
      - id: sub_ids
        type: tagged_s32
        repeat: expr
        repeat-expr: sub_id_count.value
      - id: empty2
        type: tagged_zero
      - id: pad_count
        type: tagged_s32
      - id: pad_blocks
        size: 5
        repeat: expr
        repeat-expr: pad_count.value
        doc: Opaque five-byte records skipped by the decoder.
  damage_entry:
    seq:
      - id: identity
        contents: [0x01, 0x04, 0x01, 0x01, 0x77, 0x35, 0xbb, 0x75, 0, 0, 0, 2]
      - id: base
        type: shared_base
      - id: shape_tag
        contents: [0x01]
      - id: kind
        type: s4
        valid:
          any-of: [2, 3]
        doc: 2 = sphere, 3 = capsule.
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
      - id: param0
        type: f4
      - id: param1
        type: f4
      - id: param2
        type: f4
      - id: param3
        type: f4
        doc: Sphere uses radius then direction xyz; capsule uses direction xyz then radius.
      - id: unknown_byte
        type: u1
      - id: unknown_word
        type: s4
  item_entry:
    seq:
      - id: identity
        contents: [0x01, 0x04, 0x01, 0x01, 0x77, 0x35, 0xbb, 0x75, 0, 0, 0, 2]
      - id: base
        type: shared_base
      - id: id
        type: tagged_s32
      - id: sections
        type: shape_list
  general_shape_entry:
    seq:
      - id: identity
        contents: [0x01, 0x04, 0x01, 0x01, 0x77, 0x35, 0xbb, 0x75, 0, 0, 0, 2]
      - id: base
        type: shared_base
      - id: id
        type: tagged_s32
      - id: data
        type: shape
  general_point_entry:
    seq:
      - id: identity
        contents: [0x01, 0x04, 0x01, 0x01, 0x77, 0x35, 0xbb, 0x75, 0, 0, 0, 2]
      - id: base
        type: shared_base
      - id: id
        type: tagged_s32
      - id: position_tag
        contents: [0x01]
      - id: kind
        type: s4
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
      - id: unknown_tail
        size: 16
