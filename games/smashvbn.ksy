meta:
  id: smashvbn
  endian: be
  title: Super Smash Bros. 4 VBN boneset
doc: |
  Super Smash Bros. 4 skeleton boneset (.vbn), per lib-smashvbn.c
  (ported from KillzXGaming/Smash-Forge VBN.cs). Little-endian files
  use magic " NBV" instead of "VBN " (not covered by this
  definition).
seq:
  - id: magic
    contents: "VBN "
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
  - id: bones
    type: bone_t
    repeat: expr
    repeat-expr: total_bone_count
  - id: transforms
    type: transform_t
    repeat: expr
    repeat-expr: total_bone_count
types:
  bone_t:
    seq:
      - id: name
        type: str
        size: 64
        encoding: ASCII
        terminator: 0
      - id: bone_type
        type: u4
      - id: parent_index
        type: s4
        doc: 0x0FFFFFFF marks the root.
      - id: bone_id
        type: u4
  transform_t:
    seq:
      - id: pos
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: rot
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: scale
        type: f4
        repeat: expr
        repeat-expr: 3
