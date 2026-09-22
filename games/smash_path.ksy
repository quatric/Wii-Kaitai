meta:
  id: smash_path
  endian: be
  title: Super Smash Bros. 4 stage path (path.bin)
doc: |
  Super Smash Bros. 4 stage path/camera spline (path.bin), per
  lib-smashcam.c. 12 magic bytes (not validated by the reference
  reader), s32 frame count, then frames of 7 floats (quat xyzw,
  pos xyz). The header bytes are not actually validated as magic.

  nintoolbox recognizes this only when the leaf filename is path.bin.
  It tests big-endian first and selects it when the count is 1..1000000
  and file size equals `16 + 28 * count`; otherwise it tries the same
  test under little-endian. Each frame holds a quaternion (x,y,z,w)
  followed by a position vector (x,y,z), all in the selected byte order.
  This schema chooses the same interpretation but does not itself
  validate the final file length or leaf filename.
seq:
  - id: magic
    size: 12
    doc: Opaque 12-byte prefix; no signature check is made by the reader.
  - id: frame_count_be_probe
    type: u4be
    doc: Frame count read big-endian first to decide byte order.
  - id: frames
    type: frame_t(is_le)
    repeat: expr
    repeat-expr: num_frames
instances:
  is_le:
    value: frame_count_be_probe == 0 or frame_count_be_probe > 1000000 or 16 + frame_count_be_probe * 28 != _io.size
    doc: True when big-endian fails the reference reader's exact-size test.
  num_frames:
    value: 'is_le ? ((frame_count_be_probe & 0xff) << 24) | ((frame_count_be_probe & 0xff00) << 8) | ((frame_count_be_probe & 0xff0000) >> 8) | (frame_count_be_probe >> 24) : frame_count_be_probe'
types:
  frame_t:
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
      - id: quat_x
        type: f4
        doc: Quaternion x component.
      - id: quat_y
        type: f4
        doc: Quaternion y component.
      - id: quat_z
        type: f4
        doc: Quaternion z component.
      - id: quat_w
        type: f4
        doc: Quaternion scalar w component.
      - id: pos_x
        type: f4
        doc: Position x component.
      - id: pos_y
        type: f4
        doc: Position y component.
      - id: pos_z
        type: f4
        doc: Position z component.
