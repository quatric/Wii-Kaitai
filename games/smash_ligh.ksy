meta:
  id: smash_ligh
  endian: be
  title: Super Smash Bros. 4 lighting animation (light.bin)
doc: |
  Super Smash Bros. 4 stage lighting animation (light.bin), per
  lib-smashcam.c. "LIGH" + version (4/5) + frame count [+ v5 frame
  duration] + 6 absolute offsets (light data, then 5 RGB tracks; 0 =
  disabled). Each light frame is 1988 bytes: 17 sets of four 28-byte
  light records plus four fog bytes, followed by one 16-byte effect
  record. The five optional RGB tracks carry one three-byte RGB tuple
  per frame and are padded to a four-byte boundary.

  nintoolbox accepts versions 4 and 5, 1..100000 frames, a complete
  offset header, all light frames within EOF, and each enabled RGB
  track including its padding within EOF. It does not require disabled
  track offsets to point anywhere. The source calls the tracks, in
  order: fighter Fresnel sky, fighter Fresnel ground, fighter ambient
  sky, fighter ambient ground, and reflection. Version 4 has an implicit
  frame duration of one; version 5 stores it in the header. The color
  model for each light record is hue/saturation/value, not RGB.
seq:
  - id: magic
    contents: "LIGH"
  - id: version
    type: s4
    doc: Supported values are 4 and 5.
  - id: num_frames
    type: s4
    doc: Number of light frames and RGB tuples in each enabled track.
  - id: frame_duration
    type: s4
    if: version == 5
    doc: Version 5 only; version 4 implicitly uses duration one.
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: 6
    doc: Absolute offsets; index zero is light frames, indices 1..5 RGB tracks.
instances:
  frames:
    pos: offsets[0]
    type: light_frame
    repeat: expr
    repeat-expr: num_frames
    doc: 1988-byte light frames, containing all 17 sets and the effect.
  fighter_fresnel_sky:
    pos: offsets[1]
    type: rgb_track(num_frames)
    size: num_frames * 3 + (4 - num_frames * 3 % 4) % 4
    if: offsets[1] != 0
  fighter_fresnel_ground:
    pos: offsets[2]
    type: rgb_track(num_frames)
    size: num_frames * 3 + (4 - num_frames * 3 % 4) % 4
    if: offsets[2] != 0
  fighter_ambient_sky:
    pos: offsets[3]
    type: rgb_track(num_frames)
    size: num_frames * 3 + (4 - num_frames * 3 % 4) % 4
    if: offsets[3] != 0
  fighter_ambient_ground:
    pos: offsets[4]
    type: rgb_track(num_frames)
    size: num_frames * 3 + (4 - num_frames * 3 % 4) % 4
    if: offsets[4] != 0
  reflection:
    pos: offsets[5]
    type: rgb_track(num_frames)
    size: num_frames * 3 + (4 - num_frames * 3 % 4) % 4
    if: offsets[5] != 0
types:
  light_frame:
    seq:
      - id: sets
        type: light_set
        repeat: expr
        repeat-expr: 17
      - id: effect
        type: effect_record
  light_set:
    seq:
      - id: lights
        type: light_record
        repeat: expr
        repeat-expr: 4
      - id: fog_unknown
        type: u1
        doc: Uninterpreted fog control byte preceding the RGB color.
      - id: fog_red
        type: u1
      - id: fog_green
        type: u1
      - id: fog_blue
        type: u1
  light_record:
    seq:
      - id: enabled
        type: s4
        doc: Nonzero when this light is enabled.
      - id: angle_x
        type: f4
        doc: First component of the light angle vector.
      - id: angle_y
        type: f4
        doc: Second component of the light angle vector.
      - id: angle_z
        type: f4
        doc: Third component of the light angle vector.
      - id: hue
        type: f4
        doc: Hue component of the light color.
      - id: saturation
        type: f4
        doc: Saturation component of the light color.
      - id: value
        type: f4
        doc: Value component of the light color.
  effect_record:
    seq:
      - id: unknown
        type: u1
        doc: Effect control byte; semantic meaning not established.
      - id: red
        type: u1
      - id: green
        type: u1
      - id: blue
        type: u1
      - id: position_x
        type: f4
        doc: First effect-position component.
      - id: position_y
        type: f4
        doc: Second effect-position component.
      - id: position_z
        type: f4
        doc: Third effect-position component.
  rgb_track:
    params:
      - id: count
        type: u4
    seq:
      - id: colors
        type: rgb_color
        repeat: expr
        repeat-expr: count
      - id: padding
        size-eos: true
        doc: Up to three bytes padding the RGB tuples to a four-byte boundary.
  rgb_color:
    seq:
      - id: red
        type: u1
      - id: green
        type: u1
      - id: blue
        type: u1
