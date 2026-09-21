meta:
  id: smash_cmr0
  endian: be
  title: Super Smash Bros. 4 camera motion (CMR0)
doc: |
  Super Smash Bros. 4 camera motion data, per lib-smashcam.c. No
  magic of its own; recognized by exact-size structural match. 8
  header bytes skipped by the reference reader, s32 frame count,
  then 3x4-float row-major matrices (implied fourth row 0 0 0 1).
seq:
  - id: unknown_00
    size: 8
  - id: num_frames
    type: s4
  - id: frames
    type: matrix3x4
    repeat: expr
    repeat-expr: num_frames
types:
  matrix3x4:
    seq:
      - id: row
        type: f4
        repeat: expr
        repeat-expr: 12
