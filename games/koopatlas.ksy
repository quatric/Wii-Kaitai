meta:
  id: koopatlas
  file-extension: kpbin
  application: Newer Super Mario Bros. Wii and NSMBW mods (Koopatlas world map)
  endian: be
doc: |
  Koopatlas binary world-map format (.kpbin, magic "KP_m"), as parsed by
  `lib-koopatlas.c`/`lib-koopatlas.h` of Wiimms SZS Tools. Koopatlas is
  the 2D world-map editor used by Newer Super Mario Bros. Wii and many
  NSMBW mods; maps are authored as JSON (.kpmap) and compiled into this
  optimized big-endian binary consumed by the game engine.

  Field pointer offsets are all absolute, measured from the start of the
  file. Variable-length sub-structures (layers, doodads, nodes, paths,
  worlds) are addressed indirectly through pointer arrays, matching the
  in-memory `kpbin_t`/`kp_layer_t`/... structures built by `ScanKPBin()`.
seq:
  - id: magic
    contents: [0x4b, 0x50, 0x5f, 0x6d] # "KP_m"
  - id: version
    type: s4
    doc: Typically 2.
  - id: layer_count
    type: s4
  - id: layer_offs
    type: u4
    doc: File offset to the array of layer pointers.
  - id: tileset_count
    type: s4
    doc: Number of GXTexObj tileset headers.
  - id: tileset_offs
    type: u4
  - id: unlock_offs
    type: u4
    doc: File offset to unlock bytecode.
  - id: sector_offs
    type: u4
    doc: File offset to packed 16x16 sector definitions.
  - id: bg_name_offs
    type: u4
    doc: File offset to the background image name string.
  - id: world_offs
    type: u4
    doc: File offset to the world definition list.
  - id: world_count
    type: s4
instances:
  layer_ptrs:
    io: _root._io
    pos: layer_offs
    type: u4
    repeat: expr
    repeat-expr: layer_count
    doc: Array of absolute file offsets, one per layer (kp_layer_t).
  worlds:
    io: _root._io
    pos: world_offs
    type: world
    repeat: expr
    repeat-expr: world_count
  bg_name:
    io: _root._io
    pos: bg_name_offs
    type: strz
    encoding: ASCII
types:
  layer:
    doc: |
      kp_layer_t -- one map layer. Common header, followed by
      type-specific data selected by `type` (OBJECTS: tile indices only;
      DOODADS: doodad list; PATHS: node + path lists). Sub-lists are
      addressed by their own offsets/counts, mirrored from the in-memory
      structure -- lib-koopatlas.c resolves these while walking the file
      sequentially rather than via a single fixed on-disk layer record,
      so exact byte offsets of the variable trailing data are tool-
      internal and not re-derived here.
    seq:
      - id: type
        type: u4
        enum: layer_type
      - id: alpha
        type: u1
      - id: sector_bounds
        type: s4
        repeat: expr
        repeat-expr: 4
      - id: real_bounds
        type: s4
        repeat: expr
        repeat-expr: 4

  world:
    doc: kp_world_t -- one world entry.
    seq:
      - id: world_id
        type: u1
      - id: unique_key
        type: u1
      - id: music_track_id
        type: u1
      - id: title_world
        type: u1
      - id: title_level
        type: u1
      - id: fs_text_color
        type: u4
        repeat: expr
        repeat-expr: 2
      - id: fs_hint_color
        type: u4
        repeat: expr
        repeat-expr: 2
      - id: hud_text_color
        type: u4
        repeat: expr
        repeat-expr: 2

  doodad:
    doc: kp_doodad_t -- one decorative object placement on a DOODADS layer.
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: w
        type: f4
      - id: h
        type: f4
      - id: angle
        type: f4
      - id: tex_offs
        type: u4

  doodad_anim:
    doc: kp_doodad_anim_t -- one animation track attached to a doodad.
    seq:
      - id: loop
        type: u4
      - id: curve
        type: u4
      - id: frame_count
        type: u4
      - id: type
        type: u4
        enum: anim_type
      - id: start
        type: u4
      - id: end
        type: u4
      - id: delay
        type: u4
      - id: delay_offset
        type: u4

  node:
    doc: kp_node_t -- one path node on a PATHS layer.
    seq:
      - id: x
        type: s2
      - id: y
        type: s2
      - id: exit_paths
        type: s4
        repeat: expr
        repeat-expr: 4
        doc: Indices into the path array (0=left, 1=right, 2=up, 3=down; -1=none).
      - id: tile_layer_off
        type: u4
      - id: dood_layer_off
        type: u4
      - id: type
        type: u1
        enum: node_type
      - id: level_world
        type: u1
        doc: Valid if type == LEVEL.
      - id: level_num
        type: u1
      - id: has_secret
        type: u1
      - id: this_id
        type: u1
      - id: foreign_id
        type: u1
      - id: transition
        type: u1
      - id: world_id
        type: u1
        doc: Valid if type == WORLD_CHANGE.

  path:
    doc: kp_path_t -- one connection between two nodes on a PATHS layer.
    seq:
      - id: start_node
        type: s4
        doc: Index into the node array, -1 if unresolvable.
      - id: end_node
        type: s4
      - id: tile_layer_off
        type: u4
      - id: dood_layer_off
        type: u4
      - id: is_available
        type: u1
      - id: is_secret
        type: u1
      - id: speed
        type: f4
      - id: animation
        type: u4
enums:
  node_type:
    0: passthrough
    1: stop
    2: level
    3: change
    4: world_change
  layer_type:
    0: objects
    1: doodads
    2: paths
  anim_type:
    0: x_pos
    1: y_pos
    2: angle
    3: x_scale
    4: y_scale
    5: opacity
