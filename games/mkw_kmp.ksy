meta:
  id: mkw_kmp
  file-extension: kmp
  application: Mario Kart Wii and other Nintendo EAD racing titles (KMP track data)
  endian: be
doc: |
  Nintendo EAD's KMP ("RKMD") track-data format, as parsed by `lib-kmp.c`/
  `lib-kmp.h` of Wiimms SZS Tools. Stores everything about a race track
  that isn't 3D geometry or collision: start points, AI/item routes,
  checkpoints, objects, cameras, respawn points and stage info.

  A KMP file is a small fixed file header (`kmp_file_gen_t`) followed by
  `n_sect` variable-length sections, each addressed by an offset in
  `sect_off[]` (relative to `head_size`, usually 0x4c for the 14 standard
  sections used by Mario Kart Wii). Every section begins with a common
  4-byte-magic + `n_entry`/`value` list header (`kmp_list_head_t`)
  followed by `n_entry` fixed-size entries; only `POTI` and `GOBJ`-linked
  `AREA`/`CAME` are otherwise regular. `lib-kmp-text.c` implements the
  human-readable/YAML text form of this same data (a distinct textual
  encoding, not covered here); `lib-kmp-diff.c` (semantic diffing),
  `lib-kmp-draw.c` (inserting visualization objects) and
  `lib-kmp-pflags.c` (decoding `GOBJ.pflags` bit combinations) are all
  pure in-memory algorithms over the structures below, not separate
  binary layouts, so they are not given their own `.ksy`.
seq:
  - id: header
    type: file_header
  - id: sect_off
    type: u4
    repeat: expr
    repeat-expr: header.n_sect
instances:
  ktpt:
    io: _root._io
    pos: header.head_size + sect_off[0]
    type: section(0x1c)
  enpt:
    io: _root._io
    pos: header.head_size + sect_off[1]
    type: section(0x14)
  enph:
    io: _root._io
    pos: header.head_size + sect_off[2]
    type: section(0x10)
  itpt:
    io: _root._io
    pos: header.head_size + sect_off[3]
    type: section(0x14)
  itph:
    io: _root._io
    pos: header.head_size + sect_off[4]
    type: section(0x10)
  ckpt:
    io: _root._io
    pos: header.head_size + sect_off[5]
    type: section(0x14)
  ckph:
    io: _root._io
    pos: header.head_size + sect_off[6]
    type: section(0x10)
  gobj:
    io: _root._io
    pos: header.head_size + sect_off[7]
    type: section(0x3c)
  jgpt:
    io: _root._io
    pos: header.head_size + sect_off[11]
    type: section(0x1c)
    if: header.n_sect > 11
  cnpt:
    io: _root._io
    pos: header.head_size + sect_off[12]
    type: section(0x1c)
    if: header.n_sect > 12
  mspt:
    io: _root._io
    pos: header.head_size + sect_off[13]
    type: section(0x1c)
    if: header.n_sect > 13
  stgi:
    io: _root._io
    pos: header.head_size + sect_off[14]
    type: section(0xc)
    if: header.n_sect > 14
types:
  file_header:
    doc: kmp_file_gen_t -- generic KMP file header, common to all section counts.
    seq:
      - id: magic
        contents: "RKMD"
      - id: file_size
        type: u4
      - id: n_sect
        type: u2
        doc: Number of sections that follow (14 for standard MKWii KMP; 15 with an appended WIM0 data section).
      - id: head_size
        type: u2
        doc: Size of this header including the trailing sect_off[] array; usually 0x4c.
      - id: version
        type: u4
        doc: KMP version number.

  section:
    doc: |
      kmp_list_head_t plus its `n_entry` fixed-size entries. `entry_size`
      is a parameter because entry layout differs by section (POTI is a
      variable-size group/point list handled outside this generic type).
    params:
      - id: entry_size
        type: s4
    seq:
      - id: magic
        type: str
        size: 4
        encoding: ASCII
      - id: n_entry
        type: u2
      - id: value
        type: u2
        doc: Extra per-section value (unused except POTI, where it's the total point count).
      - id: entry_bytes
        size: n_entry * entry_size
        if: entry_size > 0

  ktpt_entry:
    doc: kmp_ktpt_entry_t -- starting position of a racer.
    seq:
      - id: position
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: rotation
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: player_index
        type: s2
      - id: unknown
        type: u2

  enpt_entry:
    doc: kmp_enpt_entry_t -- one enemy (AI)/item route point.
    seq:
      - id: position
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: scale
        type: f4
      - id: prop
        type: u2
        repeat: expr
        repeat-expr: 2

  enph_entry:
    doc: kmp_enph_entry_t -- groups points into a route with up to 6 links each way.
    seq:
      - id: pt_start
        type: u1
      - id: pt_len
        type: u1
      - id: prev
        type: u1
        repeat: expr
        repeat-expr: 6
      - id: next
        type: u1
        repeat: expr
        repeat-expr: 6
      - id: setting
        type: u1
        repeat: expr
        repeat-expr: 2

  ckpt_entry:
    doc: kmp_ckpt_entry_t -- one checkpoint line.
    seq:
      - id: left
        type: f4
        repeat: expr
        repeat-expr: 2
      - id: right
        type: f4
        repeat: expr
        repeat-expr: 2
      - id: respawn
        type: u1
      - id: mode
        type: u1
      - id: prev
        type: u1
      - id: next
        type: u1

  gobj_entry:
    doc: kmp_gobj_entry_t -- one global object placement.
    seq:
      - id: obj_id
        type: u2
      - id: ref_id
        type: u2
      - id: position
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: rotation
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: scale
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: route_id
        type: u2
      - id: setting
        type: u2
        repeat: expr
        repeat-expr: 8
      - id: pflags
        type: u2
        doc: Presence-flags bitfield; decoded by lib-kmp-pflags.c, not this format definition.

  jgpt_entry:
    doc: kmp_jgpt_entry_t -- respawn point (also used verbatim for CNPT and MSPT).
    seq:
      - id: position
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: rotation
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: id
        type: s2
      - id: effect
        type: u2

  stgi_entry:
    doc: kmp_stgi_entry_t -- stage information (lap count, pole position, etc).
    seq:
      - id: lap_count
        type: u1
      - id: pole_pos
        type: u1
      - id: narrow_start
        type: u1
      - id: enable_lens_flare
        type: u1
      - id: flare_color
        type: u4
      - id: flare_alpha
        type: u1
      - id: unknown_09
        type: u1
      - id: speed_mod
        type: u2

  poti_group:
    doc: kmp_poti_group_t -- one POTI route group header, followed by n_point poti_point entries.
    seq:
      - id: n_point
        type: u2
      - id: smooth
        type: u1
      - id: back
        type: u1

  poti_point:
    doc: kmp_poti_point_t -- one point of a POTI route.
    seq:
      - id: position
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: speed
        type: u2
      - id: unknown
        type: u2

  area_entry:
    doc: kmp_area_entry_t -- camera/other trigger area.
    seq:
      - id: mode
        type: u1
      - id: type
        type: u1
      - id: dest_id
        type: u1
      - id: prio
        type: u1
      - id: position
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: rotation
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: scale
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: setting
        type: u2
        repeat: expr
        repeat-expr: 2
      - id: route
        type: u1
      - id: enemy
        type: u1
      - id: unknown_2e
        type: u2

  came_entry:
    doc: kmp_came_entry_t -- one camera definition.
    seq:
      - id: type
        type: u1
      - id: next
        type: u1
      - id: unknown_02
        type: u1
      - id: route
        type: u1
      - id: came_speed
        type: u2
      - id: zoom_speed
        type: u2
      - id: viewpt_speed
        type: u2
      - id: unknown_0a
        type: u2
      - id: position
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: rotation
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: zoom_begin
        type: f4
      - id: zoom_end
        type: f4
      - id: viewpt_begin
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: viewpt_end
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: time
        type: f4
