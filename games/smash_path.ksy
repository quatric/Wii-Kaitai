meta:
  id: smash_path
  endian: be
  title: Super Smash Bros. 4 stage path (path.bin)
doc: |
  Super Smash Bros. 4 stage path/camera spline (path.bin), per
  lib-smashcam.c. 12 magic bytes (not validated by the reference
  reader), s32 frame count, then frames of 7 floats (quat xyzw,
  pos xyz). May be little-endian on disk instead; the reference
  reader accepts either and picks whichever parses to an exact-size
  match.
seq:
  - id: magic
    size: 12
  - id: num_frames
    type: s4
  - id: frames
    type: frame_t
    repeat: expr
    repeat-expr: num_frames
types:
  frame_t:
    seq:
      - id: quat_x
        type: f4
      - id: quat_y
        type: f4
      - id: quat_z
        type: f4
      - id: quat_w
        type: f4
      - id: pos_x
        type: f4
      - id: pos_y
        type: f4
      - id: pos_z
        type: f4
