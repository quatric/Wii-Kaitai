meta:
  id: smash_cmr0
  endian: be
  title: Super Smash Bros. 4 camera motion (CMR0)
doc: |
  Super Smash Bros. 4 camera motion data, per lib-smashcam.c. No
  magic of its own; recognized by exact-size structural match. 8
  header bytes skipped by the reference reader, s32 frame count,
  then 3x4-float row-major matrices (implied fourth row 0 0 0 1).

  nintoolbox requires 1..99999 frames and a file length of exactly
  `12 + 48 * num_frames` bytes. It interprets each frame as an affine
  transform with three rows of four big-endian IEEE-754 floats. The
  first three columns are the linear transform; the fourth column is
  translation. The omitted fourth row is (0, 0, 0, 1). The first eight
  bytes are not checked for magic or version by the reference reader,
  so detection relies on the exact-size condition and context.
seq:
  - id: unknown_00
    size: 8
    doc: Opaque header bytes; not checked by the reference reader.
  - id: num_frames
    type: s4
    doc: Number of 48-byte affine matrices; detector accepts 1..99999.
  - id: frames
    type: matrix3x4
    repeat: expr
    repeat-expr: num_frames
types:
  matrix3x4:
    doc: Row-major affine matrix with an implicit fourth row of 0,0,0,1.
    seq:
      - id: row
        type: f4
        repeat: expr
        repeat-expr: 12
        doc: Twelve values grouped into three rows of four floats each.
