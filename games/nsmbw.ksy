meta:
  id: nsmbw
  endian: be
  title: New Super Mario Bros. Wii / Newer Super Mario Bros. Wii auxiliary formats
doc: |
  A grab-bag of small New Super Mario Bros. Wii (and the "Newer Super
  Mario Bros. Wii" ROM hack) formats decoded by `lib-nsmbw.c`/`.h`:

  - NWRp `LevelInfo.bin` (`nwr_level_info`): the world/level menu table.
  - NWRa `AnimTiles.bin` (`nwr_anim_tiles`): animated-tile definitions.
  - `d_bgchk_<name>.bin` (`bg_chk`): fixed 2048-byte tile behaviour table
    inside a tileset's U8 `.arc` (256 tiles x 8 bytes).

  The tileset texture (`BG_tex/<name>_tex.bin.LZ`, LZ11-compressed
  RGB4A3/RGB555 GX texel data) and object definitions
  (`BG_unt/<name>.bin` + `_hd.bin`) are not modelled here: the texture is
  a raw GX texel blob with no header of its own (see lib-nsmbw.c's
  DecodeRGB4A3), and the object-definition format is a variable-length
  byte-code stream rather than a fixed record layout.
seq: []
types:
  nwr_level_info:
    doc: '"NWRp" LevelInfo.bin, the Newer SMBW level-select menu table.'
    seq:
      - id: magic
        contents: "NWRp"
      - id: num_worlds
        type: u4
      - id: world_offsets
        type: u4
        repeat: expr
        repeat-expr: num_worlds
        doc: Absolute byte offsets to each world's entry table.
    instances:
      worlds:
        type: world(world_offsets[_index])
        repeat: expr
        repeat-expr: num_worlds
  world:
    params:
      - id: offset
        type: u4
    instances:
      table:
        pos: offset
        type: level_entry_table
        io: _root._io
  level_entry_table:
    seq:
      - id: num_entries
        type: u4
      - id: entries
        type: level_entry
        repeat: expr
        repeat-expr: num_entries
  level_entry:
    doc: |
      12 bytes. If display_level >= 100 the entry is a world header
      (100 = left title, 101 = right title) rather than an actual level.
    seq:
      - id: file_world
        type: u1
        doc: 1-indexed in the file (0-indexed on disk before display remap).
      - id: file_level
        type: u1
      - id: display_world
        type: u1
      - id: display_level
        type: u1
        doc: '>= 100 marks this entry as a world header, not a level.'
      - id: text_len
        type: u1
      - id: unk1
        type: u1
      - id: flags
        type: u2
        doc: 0x0002 star coins, 0x0010 normal exit, 0x0020 secret exit, 0x0400 right side.
      - id: text_offset
        type: u4
    instances:
      name:
        pos: text_offset
        size: text_len
        io: _root._io
        doc: |
          Bytes are shift-encoded: each byte b is stored as (b - 0x30) & 0xFF
          (see lib-nsmbw.c's ScanNWRLevelInfo), so the raw bytes here are
          not the final ASCII text.
  nwr_anim_tiles:
    doc: '"NWRa" AnimTiles.bin, the Newer SMBW animated-tile table.'
    seq:
      - id: magic
        contents: "NWRa"
      - id: num_entries
        type: u4
      - id: entries
        type: anim_tile_entry
        repeat: expr
        repeat-expr: num_entries
  anim_tile_entry:
    doc: 8 bytes.
    seq:
      - id: tex_name_offset
        type: u2
      - id: delay_offset
        type: u2
      - id: tile_num
        type: u2
      - id: tileset_num
        type: u1
        doc: Pa0-Pa3 slot (0-3).
      - id: reverse
        type: u1
    instances:
      tex_name:
        pos: tex_name_offset
        type: strz
        encoding: ASCII
        io: _root._io
      frame_delays:
        pos: delay_offset
        type: strz
        encoding: ASCII
        io: _root._io
  bg_chk:
    doc: |
      `d_bgchk_<name>.bin`, always exactly 2048 bytes: 256 tile behaviour
      records of 8 bytes each.
    seq:
      - id: tiles
        type: tile_behaviour
        repeat: expr
        repeat-expr: 256
  tile_behaviour:
    doc: 8 bytes of per-tile behaviour flags, meaning not decoded further.
    seq:
      - id: byte
        type: u1
        repeat: expr
        repeat-expr: 8
