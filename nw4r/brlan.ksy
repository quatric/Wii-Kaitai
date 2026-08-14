meta:
  id: brlan
  file-extension: brlan
  endian: be
  title: NW4R BRLAN layout animation
doc: |
  Keyframe animation for a BRLYT. Magic `RLAN`, and the same header shape
  as the layout it drives: sixteen bytes, then a flat list of tagged
  sections.

  An animation does not embed the panes it animates -- it names them. Each
  `pai1` entry carries a 20-byte pane or material name, and the runtime
  matches it against the loaded layout. That is why a `.brlan` is useless
  on its own and why the same animation file can be applied to several
  layouts that share pane names.

  Inside an entry, animation is grouped by *what* is being driven: `RLPA`
  pane transforms, `RLVC` vertex colours and pane alpha, `RLMC` material
  colours, `RLTS` texture SRT, `RLTP` texture pattern, `RLVI` visibility.
  Each of those holds one or more curves, and each curve is a list of
  keyframes.

  Offsets nest, each measured from the start of the thing that holds it:
  the entry table from the section, a tag from its entry, a key list from
  its curve.
seq:
  - id: magic
    contents: "RLAN"
  - id: bom
    type: u2
  - id: version
    type: u2
    doc: |
      0x8 and 0xa occur. Version 0xa adds the `pat1` section -- all 943
      version-0xa samples have one and none of the 360 version-0x8 samples
      do.
  - id: len_file
    type: u4
  - id: len_header
    type: u2
  - id: num_sections
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
            '"pai1"': animation_info
            '"pat1"': animation_tag

  animation_tag:
    doc: |
      `pat1`, version 0xa only. Only two things about it are established
      here: `ofs_name` resolves to a NUL-terminated tag name in all 943
      samples, and the dword at offset 0x10 of the section equals the
      section's own length in all 943. The remaining fields are left
      unnamed rather than guessed at.
    seq:
      - id: unknown_0
        type: u2
      - id: unknown_1
        type: u2
      - id: ofs_name
        type: u4
        doc: Offset from the start of the section to the tag's name.
      - id: len_section_copy
        type: u4
      - id: unknown_2
        type: u4
      - id: flags
        type: u1
      - id: reserved
        size: 3
    instances:
      name:
        pos: ofs_name - 8
        type: strz
        encoding: ASCII
        if: ofs_name >= 8

  animation_info:
    doc: |
      `pai1`. `ofs_entries` is relative to the start of the section, so 8
      is subtracted to index into this body.
    seq:
      - id: num_frames
        type: u2
      - id: is_looping
        type: u1
      - id: reserved
        type: u1
      - id: num_textures
        type: u2
        doc: |
          Count of texture names used by `RLTP` pattern animation, held in
          a table between this header and the entry list. Zero in 1274 of
          1303 samples; the table's exact stride was not pinned down, so
          reach the entries through `ofs_entries` rather than by stepping
          past it.
      - id: num_entries
        type: u2
      - id: ofs_entries
        type: u4
    instances:
      entries:
        pos: ofs_entries - 8
        type: entry_ref
        repeat: expr
        repeat-expr: num_entries

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
        size: 20
        encoding: ASCII
        pad-right: 0
      - id: num_tags
        type: u1
      - id: target_type
        type: u1
        doc: |
          0 when `name` is a pane, 1 when it is a material. Both occur
          (4114 and 3353 across the sample set), so this cannot be
          ignored -- the two namespaces are separate.
      - id: reserved
        type: u2
      - id: tags
        type: tag_ref(self_ofs)
        repeat: expr
        repeat-expr: num_tags
        doc: |
          Each holds one offset from the start of this entry to a tag
          block, and resolves it.

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
    doc: |
      A group of curves sharing one target kind. `magic` is one of RLPA,
      RLVC, RLMC, RLTS, RLTP, RLVI.
    params:
      - id: self_ofs
        type: s4
    seq:
      - id: magic
        type: str
        size: 4
        encoding: ASCII
      - id: num_curves
        type: u1
      - id: reserved
        size: 3
      - id: curves
        type: curve_ref(self_ofs)
        repeat: expr
        repeat-expr: num_curves
        doc: |
          Each holds one offset from the start of this tag block to a
          curve record, and resolves it.

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
      kind is driven -- for `RLVC`, 0 to 15 are the four corner colours
      and 16 is the pane's own alpha.
    params:
      - id: self_ofs
        type: s4
    seq:
      - id: index
        type: u1
        doc: |
          Sub-index within the target, used when a tag drives several
          slots of the same kind (a material with more than one texture
          matrix, for instance). 0 in the overwhelming majority of curves
          but observed up to 9.
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
