meta:
  id: dpgz
  title: Petz displacement track (DPGZ, Petz Sports)
  endian: be
doc: |
  {u32 magic, u32 header word count (15 or 30), floats up to 0x40, u32 frame
  count @0x40, f32 length @0x44}, then sections {u32 n, n x (3 f32)} twice
  (position path, scale), optionally a third {u32 n, n x f32}, and a trailing
  u32 0.
seq:
  - id: magic
    type: u4
  - id: header_word_count
    type: u4
  - id: header_floats
    type: f4
    repeat: expr
    repeat-expr: 14
  - id: frame_count
    type: u4
  - id: length
    type: f4
  - id: rest
    size-eos: true
types:
  vec3_section:
    seq:
      - id: n
        type: u4
      - id: keys
        type: f4
        repeat: expr
        repeat-expr: n * 3
