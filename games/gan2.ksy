meta:
  id: gan2
  title: Grasshopper Manufacture GAN2 animation (.GA2)
  file-extension: ga2
  endian: be
doc: |
  Grasshopper Manufacture `GAN2` animation (No More Heroes `.GA2` members of
  RMHG containers). The header is big-endian, the tracks little-endian. Track
  data (derived from 800 retail tracks): `{u16 0, u16 channel mask, u32 0,
  u32 end, u32 channel count at +0xc, ..., u32 channel offset list at +0x1c}`; a
  channel is `{u16 1 (3 = other), u16 id (0-2 translation, 3-5 rotation), u32 0,
  u32 data offset, u32 0}`; channel data is `{u8 format, u8 parameter, u8 frame
  count, u8 0}` + frames: format 5 = little-endian s16 scaled by 2^(16 -
  parameter), formats 1 and 4 = little-endian float32 (unverified).
seq:
  - id: magic
    contents: GAN2
  - id: one
    type: u4
  - id: zero0
    type: u4
  - id: len_file
    type: u4
  - id: zero1
    type: u4
  - id: num_tracks
    type: u4
  - id: reserved
    size: 0x18
  - id: tracks
    type: track
    repeat: expr
    repeat-expr: num_tracks
types:
  track:
    meta:
      endian: le
    seq:
      - id: name
        size: 16
        type: strz
        encoding: ASCII
      - id: parent
        type: u4
        doc: File offset of another track, 0 = none.
      - id: first_child
        type: u4
      - id: previous
        type: u4
      - id: next
        type: u4
      - id: data_offset
        type: u4
        doc: 0 = no keys.
