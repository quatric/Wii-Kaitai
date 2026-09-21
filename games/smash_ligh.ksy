meta:
  id: smash_ligh
  endian: be
  title: Super Smash Bros. 4 lighting animation (light.bin)
doc: |
  Super Smash Bros. 4 stage lighting animation (light.bin), per
  lib-smashcam.c. "LIGH" + version (4/5) + frame count [+ v5 frame
  duration] + 6 absolute offsets (light data, then 5 RGB tracks; 0 =
  disabled). Light-frame bodies (17 sets of 4 lights with angle/hue/
  sat/val plus fog, then an effect record) are documented in the
  source but not expanded here.
seq:
  - id: magic
    contents: "LIGH"
  - id: version
    type: s4
  - id: num_frames
    type: s4
  - id: frame_duration
    type: s4
    if: version == 5
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: 6
