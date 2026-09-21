meta:
  id: bflan
  file-extension: bflan
  endian: le
  title: NintendoWare BFLAN layout animation
doc: |
  Keyframe animation for a BFLYT, and the 3DS/Wii U successor to BRLAN.
  Magic `FLAN`, same 20-byte header as the layout it drives, then a `pat1`
  tag block and a `pai1` animation block.

  The structure is BRLAN's with wider fields and one addition. An
  animation still names the panes and materials it drives rather than
  embedding them, so a `.bflan` is inert on its own and can be applied to
  any layout sharing those names. Curve groups keep the same six kinds,
  renamed from `RL**` to `FL**`: `FLPA` pane transforms, `FLVC` vertex
  colours and pane alpha, `FLMC` material colours, `FLTS` texture SRT,
  `FLTP` texture pattern, `FLVI` visibility.

  What is new is that `pai1` carries its own texture-name table, so a
  pattern animation can name the images it cycles through without going
  back to the layout.

  Offsets nest, each from the start of whatever holds it: the entry table
  from the section, a tag from its entry, a curve from its tag, a key list
  from its curve. The two name tables are the exception and are relative
  to the start of their own offset table.

  Like `bflyt.ksy`, this is nominally an NW4C (NintendoWare for CTR)
  format, but the NW4F (Cafe/Wii U) `Lyt` library's animation files share
  the same `FLAN` magic and section layout, byte order aside, so this
  definition is not restricted to 3DS files.

  Widths were measured, not assumed: an animation entry's name is 28 bytes
  -- across 5371 entries in the sample set, 28 is the only width for which
  the name is clean ASCII, the padding is all NUL, and the two bytes after
  it are a plausible tag count and target type.
seq:
  - id: magic
    contents: "FLAN"
  - id: bom
    type: u2
  - id: len_header
    type: u2
    doc: 0x14.
  - id: version
    type: u4
    doc: 0x07020100 across all 900 samples.
  - id: len_file
    type: u4
  - id: num_sections
    type: u2
  - id: reserved
    type: u2
  - id: sections
    type: section
    repeat: expr
    repeat-expr: num_sections
types:
  section:
    seq:
      - id: magic
        type: str
        size: 4
        encoding: ASCII
      - id: len_section
        type: u4
      - id: body
        size: len_section - 8
        type:
          switch-on: magic
          cases:
            '"pat1"': animation_tag
            '"pai1"': animation_info

  animation_tag:
    doc: |
      `pat1`. Names the animation and lists the layout groups it applies
      to, and gives the frame range the tag covers. Both offsets are
      relative to the start of the section, so 8 is subtracted to index
      into this body.
    seq:
      - id: order
        type: u2
      - id: num_groups
        type: u2
      - id: ofs_name
        type: u4
      - id: ofs_group_names
        type: u4
      - id: start_frame
        type: u2
      - id: end_frame
        type: u2
      - id: is_looping
        type: u1
      - id: reserved
        size: 3
    instances:
      name:
        pos: ofs_name - 8
        type: strz
        encoding: ASCII
        if: ofs_name >= 8
      group_names:
        pos: ofs_group_names - 8
        type: str
        size: 36
        encoding: ASCII
        pad-right: 0
        repeat: expr
        repeat-expr: num_groups
        if: ofs_group_names >= 8
        doc: |
          Group names in a BFLYT are 34 bytes; here they are stored on a
          36-byte stride, which is what `(len_section - ofs_group_names) /
          num_groups` comes to in every one of the 900 samples.

  animation_info:
    doc: |
      `pai1`. `ofs_entries` is relative to the start of the section; the
      texture-name offsets are relative to the start of their own table,
      which begins 20 bytes into the section.
    seq:
      - id: num_frames
        type: u2
      - id: is_looping
        type: u2
      - id: num_textures
        type: u2
      - id: num_entries
        type: u2
      - id: ofs_entries
        type: u4
      - id: textures
        type: texture_ref
        repeat: expr
        repeat-expr: num_textures
        doc: Images a `FLTP` pattern animation cycles through.
    instances:
      entries:
        pos: ofs_entries - 8
        type: entry_ref
        repeat: expr
        repeat-expr: num_entries

  texture_ref:
    seq:
      - id: ofs_name
        type: u4
    instances:
      name:
        io: _parent._io
        pos: ofs_name + 12
        type: strz
        encoding: ASCII
        doc: |
          `+ 12` converts from "relative to the texture offset table" to
          "relative to this body": the table starts after the four u2
          counters and `ofs_entries`.

  entry_ref:
    seq:
      - id: ofs_entry
        type: u4
        doc: Offset from the start of the section to one animated target.
    instances:
      entry:
        io: _parent._io
        pos: ofs_entry - 8
        type: animation_entry(ofs_entry - 8)

  animation_entry:
    doc: One animated pane or material, named rather than pointed at.
    params:
      - id: self_ofs
        type: s4
    seq:
      - id: name
        type: str
        size: 28
        encoding: ASCII
        pad-right: 0
      - id: num_tags
        type: u1
      - id: target_type
        type: u1
        doc: 0 when `name` is a pane, 1 when it is a material.
      - id: reserved
        type: u2
      - id: tags
        type: tag_ref(self_ofs)
        repeat: expr
        repeat-expr: num_tags

  tag_ref:
    params:
      - id: base_ofs
        type: s4
    seq:
      - id: ofs_tag
        type: u4
    instances:
      tag:
        pos: base_ofs + ofs_tag
        type: tag(base_ofs + ofs_tag)

  tag:
    doc: A group of curves sharing one target kind.
    params:
      - id: self_ofs
        type: s4
    seq:
      - id: magic
        type: str
        size: 4
        encoding: ASCII
        doc: One of FLPA, FLVC, FLMC, FLTS, FLTP, FLVI.
      - id: num_curves
        type: u1
      - id: reserved
        size: 3
      - id: curves
        type: curve_ref(self_ofs)
        repeat: expr
        repeat-expr: num_curves

  curve_ref:
    params:
      - id: base_ofs
        type: s4
    seq:
      - id: ofs_curve
        type: u4
    instances:
      curve:
        pos: base_ofs + ofs_curve
        type: curve(base_ofs + ofs_curve)

  curve:
    doc: |
      One animated channel. `target` selects which property of the tag's
      kind is driven; for `FLVC`, 0 to 15 are the four corner colours and
      16 is the pane's own alpha.
    params:
      - id: self_ofs
        type: s4
    seq:
      - id: index
        type: u1
        doc: |
          Sub-index within the target, for tags driving several slots of
          the same kind. 0 for 19121 of the 19457 curves in the samples.
      - id: target
        type: u1
      - id: curve_type
        type: u1
        enum: curve_kind
      - id: reserved
        type: u1
      - id: num_keys
        type: u2
      - id: reserved2
        type: u2
      - id: ofs_keys
        type: u4
        doc: Offset from the start of this curve record to its key list.
    instances:
      keys_hermite:
        pos: self_ofs + ofs_keys
        type: key_hermite
        repeat: expr
        repeat-expr: num_keys
        if: curve_type == curve_kind::hermite
      keys_step:
        pos: self_ofs + ofs_keys
        type: key_step
        repeat: expr
        repeat-expr: num_keys
        if: curve_type == curve_kind::step

  key_hermite:
    doc: |
      Frame, value and tangent. Values are in the target's own units, so
      an alpha curve runs 0 to 255 rather than 0 to 1.
    seq:
      - id: frame
        type: f4
      - id: value
        type: f4
      - id: slope
        type: f4

  key_step:
    doc: |
      Used by discrete channels such as visibility and texture pattern:
      the value holds until the next key.
    seq:
      - id: frame
        type: f4
      - id: value
        type: u2
      - id: reserved
        type: u2
enums:
  curve_kind:
    1: step
    2: hermite
