meta:
  id: imaginewa2
  title: Imagine engine skeletal animation (.wa2, Beastly)
  file-extension: wa2
  endian: be
doc: |
  After unpacking the Imagine LZ wrapper. A bone is {u32 index, float x, y, z
  (bind translation), u32 child count, u32 0, u32 child indices[count]}. A
  clip is {u32 frame count N, u32 0, 4 runtime words, u32 flags[N], float3
  root motion[N], float3 second track[N], then N frames of bone quaternions
  {x, y, z, w}[bones]}; occupying 0x18 + N * (0x1c + 16 * bones) bytes.
seq:
  - id: clip_count
    type: u4
  - id: bone_count
    type: u4
  - id: bone_offsets
    type: u4
    repeat: expr
    repeat-expr: bone_count
  - id: clip_offsets
    type: u4
    repeat: expr
    repeat-expr: clip_count
types:
  bone:
    seq:
      - id: index
        type: u4
      - id: translation
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: child_count
        type: u4
      - id: runtime
        type: u4
      - id: children
        type: u4
        repeat: expr
        repeat-expr: child_count
  clip_head:
    seq:
      - id: frame_count
        type: u4
      - id: zero
        type: u4
      - id: runtime
        type: u4
        repeat: expr
        repeat-expr: 4
