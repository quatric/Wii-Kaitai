meta:
  id: nuanmb
  file-extension: nuanmb
  endian: le
  title: Bandai Namco SSBH skeletal/material animation (Super Smash Bros. Ultimate)
doc: |
  SSBH ANIM container (`.nuanmb`), Super Smash Bros. Ultimate. Reference:
  ultimate-research/ssbh_lib `ssbh_lib/src/formats/anim.rs`
  (`Anim::V12`/`V20`/`V21`). Ported from `lib-nuanmb.c`/`.h`.

  The per-frame keyframe bytes referenced by each TrackV2's data_offset/
  data_size (a bit-packed compression scheme documented only in the
  companion ssbh_data crate, not ssbh_lib) are not decoded by this
  definition, matching lib-nuanmb.c's own documented scope.
seq:
  - id: magic
    contents: [0x48, 0x42, 0x53, 0x53] # "HBSS"
  - id: unk1
    type: u8
    doc: Always 0x40 on retail files.
  - id: sub_magic
    contents: [0x4d, 0x49, 0x4e, 0x41] # "MINA" ("ANIM" byte-reversed)
  - id: version_major
    type: u2
  - id: version_minor
    type: u2
  - id: body
    type:
      switch-on: version_major
      cases:
        1: anim_v1
        2: anim_v2
types:
  ssbh_array:
    seq:
      - id: ofs_rel
        type: u8
      - id: count
        type: u8
  ssbh_string:
    seq:
      - id: ofs_rel
        type: u8
  anim_v1:
    doc: Version 1.2, older flat track list.
    seq:
      - id: name
        type: ssbh_string
      - id: unk1
        type: f4
      - id: final_frame_index
        type: f4
      - id: unk2
        type: f4
      - id: unk3
        type: f4
      - id: tracks
        type: ssbh_array
        doc: SsbhArray<TrackV1>, element size 0x20.
      - id: buffers
        type: ssbh_array
        doc: SsbhArray<SsbhByteBuffer>.
  track_v1:
    doc: 0x20 bytes.
    seq:
      - id: name
        type: ssbh_string
      - id: track_type
        type: u8
        doc: 0 Transform, 2 UvTransform, 5 Visibility.
      - id: properties
        type: ssbh_array
        doc: SsbhArray<Property>, element size 0x10.
  property:
    doc: 0x10 bytes.
    seq:
      - id: name
        type: ssbh_string
      - id: buffer_index
        type: u8
        doc: Indexes the file-level 'buffers' array.
  anim_v2:
    doc: Version 2.0/2.1, group -> node -> track hierarchy.
    seq:
      - id: final_frame_index
        type: f4
      - id: unk1
        type: u2
      - id: unk2
        type: u2
      - id: name
        type: ssbh_string
      - id: groups
        type: ssbh_array
        doc: SsbhArray<Group>, element size 0x18.
      - id: buffer
        type: byte_buffer
      - id: unk_data
        size: 0x20
        if: _parent.version_minor == 1
        doc: |
          Version 2.1 only -- two SsbhArrays not decoded further; the
          reference itself marks their element types' fields TODO.
  byte_buffer:
    seq:
      - id: ofs_rel
        type: u8
      - id: size
        type: u8
  group:
    doc: 0x18 bytes.
    seq:
      - id: group_type
        type: u8
        doc: 1 Transform, 2 Visibility, 4 Material, 5 Camera.
      - id: nodes
        type: ssbh_array
        doc: SsbhArray<Node>, element size 0x18.
  node:
    doc: 0x18 bytes.
    seq:
      - id: name
        type: ssbh_string
      - id: tracks
        type: ssbh_array
        doc: SsbhArray<TrackV2>, element size 0x20.
  track_v2:
    doc: 0x20 bytes.
    seq:
      - id: name
        type: ssbh_string
      - id: track_type
        type: u1
        doc: 1 Transform, 2 UvTransform, 3 Float, 5 PatternIndex, 8 Boolean, 9 Vector4.
      - id: compression_type
        type: u1
        doc: 1 Direct, 2 ConstTransform, 4 Compressed, 5 Constant.
      - id: padding
        size: 2
      - id: frame_count
        type: u4
      - id: transform_flags
        type: u4
        doc: |
          bit 0 override_translation, bit 1 override_rotation,
          bit 2 override_scale, bit 3 override_compensate_scale.
      - id: data_offset
        type: u4
        doc: Into the file-level anim_v2 'buffer' above.
      - id: data_size
        type: u8
