meta:
  id: smashvbn
  endian: be
  title: Super Smash Bros. 4 VBN boneset
doc: |
  Super Smash Bros. 4 skeleton boneset (.vbn), per lib-smashvbn.c
  (ported from KillzXGaming/Smash-Forge VBN.cs). Big-endian files use
  magic `VBN `; little-endian files use ` NBV`. The magic selects the
  byte order of counts, IDs, parent indices, and transform floats.
  Four header counts enumerate normal, follow, helper, and swing bones.
  Each 76-byte bone record is followed, after the complete bone table,
  by a corresponding 36-byte transform of position xyz, rotation
  xyz, and scale xyz.

  nintoolbox requires 1..100000 bones, exact length `28 + 112 * count`,
  a NUL within each fixed 64-byte name, and each parent index either
  0x0fffffff (root) or a valid zero-based bone index. Bone types 0..3
  are printed as Normal, Follow, Helper, and Swing; other values are
  retained as unknown. The four category counts are reported but not
  checked against the records' bone types.
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
    valid:
      any-of: ['"VBN "', '" NBV"']
  - id: content
    type: content_t(is_le)
instances:
  is_le:
    value: magic == " NBV"
types:
  content_t:
    params:
      - id: little_endian
        type: bool
    meta:
      endian:
        switch-on: little_endian
        cases:
          true: le
          false: be
    seq:
      - id: unk1
        type: s2
      - id: unk2
        type: s2
      - id: total_bone_count
        type: u4
      - id: bone_count_per_type
        type: u4
        repeat: expr
        repeat-expr: 4
        doc: Normal, follow, helper, then swing counts.
      - id: bones
        type: bone_t(little_endian)
        repeat: expr
        repeat-expr: total_bone_count
      - id: transforms
        type: transform_t(little_endian)
        repeat: expr
        repeat-expr: total_bone_count
  bone_t:
    params:
      - id: little_endian
        type: bool
    meta:
      endian:
        switch-on: little_endian
        cases:
          true: le
          false: be
    seq:
      - id: name
        type: str
        size: 64
        encoding: ASCII
        terminator: 0
      - id: bone_type
        type: u4
        doc: 0 normal, 1 follow, 2 helper, 3 swing; others unknown.
      - id: parent_index
        type: s4
        doc: 0x0fffffff marks a root; otherwise a zero-based bone index.
      - id: bone_id
        type: u4
        doc: Stored identifier of this bone.
  transform_t:
    params:
      - id: little_endian
        type: bool
    meta:
      endian:
        switch-on: little_endian
        cases:
          true: le
          false: be
    seq:
      - id: pos
        type: f4
        repeat: expr
        repeat-expr: 3
        doc: Position xyz.
      - id: rot
        type: f4
        repeat: expr
        repeat-expr: 3
        doc: Rotation xyz.
      - id: scale
        type: f4
        repeat: expr
        repeat-expr: 3
        doc: Scale xyz.
