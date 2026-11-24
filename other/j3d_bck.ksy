meta:
  id: j3d_bck
  title: J3D joint animation (.bck)
  file-extension: bck
  endian: be
doc: |
  J3D joint animation `BCK` (`J3D1bck1` + `ANK1` chunk; GameCube/Wii). Every
  joint has 9 tracks (scale, rotation, translation for x, y, z) of `{u16 key
  count, u16 table index, u16 tangent type}`; a single key is a constant,
  otherwise keys are `{time, value, tangent in[, tangent out]}` (3 values, or 4
  when the tangent type is 1) in the track's table type. Rotation values are s16
  where 0x8000 = 180 degrees << angle multiplier. `BTK` (`TTK1`, texture SRT
  animation) uses the same tracks per texture matrix entry with the tables at
  +0x28/0x2c/0x30. Chunk offsets are relative to the chunk.
seq:
  - id: magic
    contents: 'J3D1bck1'
  - id: len_file
    type: u4
  - id: num_chunks
    type: u4
  - id: subversion
    size: 16
  - id: ank1
    type: ank1
types:
  ank1:
    seq:
      - id: tag
        contents: ANK1
      - id: len_chunk
        type: u4
      - id: loop_mode
        type: u1
      - id: angle_multiplier
        type: u1
      - id: duration
        type: u2
      - id: num_joints
        type: u2
      - id: len_scale_table
        type: u2
      - id: len_rotation_table
        type: u2
      - id: len_translation_table
        type: u2
      - id: joints_offset
        type: u4
      - id: scale_offset
        type: u4
      - id: rotation_offset
        type: u4
      - id: translation_offset
        type: u4
  track:
    seq:
      - id: num_keys
        type: u2
      - id: table_index
        type: u2
      - id: tangent_type
        type: u2
  joint:
    seq:
      - id: tracks
        type: track
        repeat: expr
        repeat-expr: 9
        doc: scale xyz, rotation xyz, translation xyz.
