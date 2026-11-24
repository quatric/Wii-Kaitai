meta:
  id: sega_hmot
  title: SEGA HMOT motion (Sakura Wars So Long My Love)
  file-extension: hmot
  endian: le
doc: |
  KFMO chunk at 0x20 whose offsets are relative to 0x20. Bone table entries
  are 16 bytes {0, channel mask << 24, curve offset list (0 = none), base
  values}. Channels follow set mask bits from bit 0 (0-3 rotation, 4 unused,
  5-7 translation xyz). Base values: one f32 per set bit; curve offsets: one
  u32 per set bit (0 = static). Curve: {u8 1, u8 bytes per sample, u8 binary
  point, 0, 8 zero bytes, u32 samples offset}; 2-byte samples are frames + 1
  s16 values / 2^binary_point.
seq:
  - id: magic
    contents: HMOT
  - id: size
    type: u4
  - id: header_size
    type: u4
    doc: 0x20.
  - id: zero
    type: u4
  - id: pad
    size: 0x20 - 16
  - id: kfmo
    type: kfmo
types:
  kfmo:
    seq:
      - id: magic
        contents: KFMO
      - id: size
        type: u4
      - id: header_size
        type: u4
        doc: 0x10.
      - id: zero
        type: u4
      - id: flags
        type: u4
      - id: bone_count
        type: u2
      - id: one
        type: u2
      - id: frame_count
        type: f4
      - id: bone_table_offset
        type: u4
    instances:
      bones:
        pos: 0x20 + bone_table_offset
        type: bone
        repeat: expr
        repeat-expr: bone_count
        io: _root._io
  bone:
    seq:
      - id: zero
        type: u4
      - id: mask_shifted
        type: u4
        doc: channel mask << 24.
      - id: curve_offsets_offset
        type: u4
      - id: base_values_offset
        type: u4
  curve:
    seq:
      - id: one
        type: u1
      - id: bytes_per_sample
        type: u1
      - id: binary_point
        type: u1
      - id: zero
        type: u1
      - id: pad
        size: 8
      - id: samples_offset
        type: u4
