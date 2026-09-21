meta:
  id: clr0
  file-extension: clr0
  endian: be
  imports:
    - brres_sub_header
  title: NW4R CLR0 material colour animation
doc: |
  Animates up to 11 GX colour targets per named material: the two light
  channel material colours, the two light channel ambient colours, the
  three TEV colour registers and the four TEV konstant registers, in that
  fixed order. Each target is either absent, a single constant RGBA, or
  one RGBA value per frame (`num_frames + 1` values -- an extra
  terminating frame like CHR0/SRT0 also carry).

  Each material's `flags` word packs one "exists" and one "constant" bit
  per target (`bit 2*t` / `bit 2*t+1`), and only the *existing* targets'
  8-byte records are physically present, packed back to back in target
  order -- there is no record at all for an absent target. A record holds
  a colour mask and either the constant RGBA (if "constant") or an offset
  such that the per-frame colour array lives at
  `<record address> + data + 4`.
seq:
  - id: header
    type: brres_sub_header
  - id: ofs_data
    type: s4
    doc: Offset from the start of this CLR0 to the material resource group.
  - id: ofs_user_data
    type: s4
    if: header.version == 4
  - id: ofs_name
    type: s4
  - id: ofs_orig_path
    type: s4
  - id: num_frames
    type: u2
  - id: num_entries
    type: u2
  - id: loop
    type: u4
instances:
  name:
    pos: ofs_name - 4
    type: pooled_string
    if: ofs_name != 0
  orig_path:
    pos: ofs_orig_path - 4
    type: pooled_string
    if: ofs_orig_path != 0
  num_color:
    value: num_frames + 1
    doc: Number of RGBA values a non-constant target stores.
  group:
    pos: ofs_data
    type: resource_group(ofs_data)
    if: ofs_data != 0
types:
  pooled_string:
    seq:
      - id: len_name
        type: u4
      - id: name
        type: str
        size: len_name
        encoding: ASCII

  resource_group:
    doc: Standard BRRES resource group -- entry 0 is a sentinel, excluded from `num_entries`.
    params:
      - id: base_ofs
        type: s4
    seq:
      - id: len_group
        type: u4
      - id: num_entries
        type: u4
      - id: entries
        type: resource_entry(base_ofs)
        repeat: expr
        repeat-expr: num_entries + 1

  resource_entry:
    doc: One lookup-tree record; `ofs_data` leads to the actual material entry.
    params:
      - id: base_ofs
        type: s4
    seq:
      - id: id
        type: u2
      - id: reserved
        type: u2
      - id: idx_left
        type: u2
      - id: idx_right
        type: u2
      - id: ofs_name
        type: s4
      - id: ofs_data
        type: s4
    instances:
      name:
        pos: base_ofs + ofs_name - 4
        type: pooled_string
        if: ofs_name != 0
      entry:
        pos: base_ofs + ofs_data
        type: clr0_entry(base_ofs + ofs_data, _root.num_color)
        if: ofs_data != 0

  clr0_entry:
    doc: |
      One animated material. `ofs_name` here is relative to the start of
      this entry, independent of the lookup record's own name pointer.
      Target fields `t0`..`t10` -- in the fixed order matcolor0,
      matcolor1, ambient0, ambient1, tevreg0, tevreg1, tevreg2, konst0,
      konst1, konst2, konst3 -- occupy zero bytes when their "exists" bit
      is clear.
    params:
      - id: self_pos
        type: s4
        doc: Absolute file offset of this entry's first byte (the `ofs_name` field).
      - id: num_color
        type: u4
    seq:
      - id: ofs_name
        type: s4
      - id: flags
        type: u4
        doc: 11 target bit-pairs; bit `2*t` = target `t` exists, bit `2*t+1` = constant.
      - id: t0
        type: target_record((flags >> 1 & 1) != 0, num_color)
        if: (flags >> 0 & 1) != 0
      - id: t1
        type: target_record((flags >> 3 & 1) != 0, num_color)
        if: (flags >> 2 & 1) != 0
      - id: t2
        type: target_record((flags >> 5 & 1) != 0, num_color)
        if: (flags >> 4 & 1) != 0
      - id: t3
        type: target_record((flags >> 7 & 1) != 0, num_color)
        if: (flags >> 6 & 1) != 0
      - id: t4
        type: target_record((flags >> 9 & 1) != 0, num_color)
        if: (flags >> 8 & 1) != 0
      - id: t5
        type: target_record((flags >> 11 & 1) != 0, num_color)
        if: (flags >> 10 & 1) != 0
      - id: t6
        type: target_record((flags >> 13 & 1) != 0, num_color)
        if: (flags >> 12 & 1) != 0
      - id: t7
        type: target_record((flags >> 15 & 1) != 0, num_color)
        if: (flags >> 14 & 1) != 0
      - id: t8
        type: target_record((flags >> 17 & 1) != 0, num_color)
        if: (flags >> 16 & 1) != 0
      - id: t9
        type: target_record((flags >> 19 & 1) != 0, num_color)
        if: (flags >> 18 & 1) != 0
      - id: t10
        type: target_record((flags >> 21 & 1) != 0, num_color)
        if: (flags >> 20 & 1) != 0
    instances:
      name:
        pos: self_pos + ofs_name - 4
        type: pooled_string
        if: ofs_name != 0

  target_record:
    doc: |
      One 8-byte colour-target record. `raw_data` is the constant RGBA
      when `is_constant`; otherwise it is an offset such that the
      per-frame colour array starts at
      `(this record's address) + raw_data + 4`.
    params:
      - id: is_constant
        type: bool
      - id: num_color
        type: u4
    seq:
      - id: mask
        type: u4
        doc: RGBA colour mask applied to the source colour.
      - id: raw_data
        type: u4
    instances:
      color:
        value: raw_data
        if: is_constant
      colors:
        pos: _io.pos - 4 + raw_data
        type: u4
        repeat: expr
        repeat-expr: num_color
        if: not is_constant
