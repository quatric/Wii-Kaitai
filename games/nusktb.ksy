meta:
  id: nusktb
  file-extension: nusktb
  endian: le
  title: Bandai Namco SSBH skeleton (Super Smash Bros. Ultimate)
doc: |
  SSBH SKEL container. Every pointer is a 64-bit offset relative to the
  field that holds it. `bone_entries` and the four Matrix4x4 arrays
  (world/inverse-world/local/inverse-local transforms) are parallel,
  one element per bone.

  Reference: nintoolbox project/src/lib-nusktb.c (DecodeNUSKTB_Text),
  itself following ultimate-research/ssbh_lib's skel.rs (Skel::V10),
  verified there against 151 retail skeletons.
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
    valid:
      any-of: ['"HBSS"', '"SSBH"']
  - id: unk_08
    type: u8
    doc: Always 0x40 on retail files.
  - id: sub_magic
    type: str
    size: 4
    encoding: ASCII
    valid:
      any-of: ['"LEKS"', '"SKEL"']
  - id: version_major
    type: u2
  - id: version_minor
    type: u2
  - id: bone_entries
    type: ssbh_array(_io.pos)
  - id: world_transforms
    type: ssbh_array(_io.pos)
  - id: inv_world_transforms
    type: ssbh_array(_io.pos)
  - id: transforms
    type: ssbh_array(_io.pos)
  - id: inv_transforms
    type: ssbh_array(_io.pos)
instances:
  bones:
    pos: bone_entries.ofs_absolute
    type: bone_entry
    repeat: expr
    repeat-expr: bone_entries.count
    if: bone_entries.ofs_relative != 0
  world_matrices:
    pos: world_transforms.ofs_absolute
    type: matrix4x4
    repeat: expr
    repeat-expr: world_transforms.count
    if: world_transforms.ofs_relative != 0
types:
  ssbh_array:
    doc: One SsbhArray field -- u8 relative offset (relative to its own position) + u8 count.
    params:
      - id: field_pos
        type: u8
    seq:
      - id: ofs_relative
        type: s8
      - id: count
        type: u8
    instances:
      ofs_absolute:
        value: field_pos + ofs_relative

  ssbh_string:
    doc: SsbhString field -- u8 relative offset (relative to its own position) to a NUL-terminated string.
    params:
      - id: field_pos
        type: u8
    seq:
      - id: ofs_relative
        type: s8
    instances:
      value:
        pos: field_pos + ofs_relative
        type: strz
        encoding: UTF-8
        if: ofs_relative != 0

  bone_entry:
    doc: One SkelBoneEntry, 0x10 bytes.
    seq:
      - id: name
        type: ssbh_string(_io.pos)
      - id: index
        type: u2
      - id: parent_index
        type: s2
        doc: -1 if this bone has no parent.
      - id: flag_unk1
        type: u1
      - id: billboard_type
        type: u1
        enum: billboard_type
      - id: padding
        size: 2

  matrix4x4:
    doc: 16 little-endian floats; the translation lives at indices 12/13/14 (bytes 0x30/0x34/0x38).
    seq:
      - id: values
        type: f4
        repeat: expr
        repeat-expr: 16
enums:
  billboard_type:
    0: disabled
    1: x_axis_view_point_aligned
    2: y_axis_view_point_aligned
    3: unk3
    4: xy_axis_view_point_aligned
    6: y_axis_view_plane_aligned
    8: xy_axis_view_plane_aligned
