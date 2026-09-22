meta:
  id: smashomo
  endian: be
  title: Super Smash Bros. 4 object-motion animation (OMO)
doc: |
  Super Smash Bros. 4 object-motion skeletal animation (.omo), per
  lib-smashomo.c (ported from KillzXGaming/Smash-Forge OMO.cs). The
  header is 32 bytes. Each bone node points to interpolation floats at
  `inter_offset + inter_rel_offset`; its flag word determines the number
  of floats. Frame keys are rows of big-endian 16-bit values at key_offset,
  with frame_size bytes per row. The node's own key-offset word is printed
  by the decoder but not used to locate those frame rows.

  Flags 0x01000000, 0x02000000, and 0x04000000 enable position, rotation,
  and scale respectively. Enabled position is constant (0x00200000,
  three floats) or interpolated (0x00080000, six floats). Rotation's
  mode nibble is constant 0x7000 (three floats), full constant 0x6000
  (four floats), interpolated 0x5000 (six floats), or per-frame 0xa000
  (no interpolation floats). Scale uses constant 0x200/0x300 (three
  floats) or interpolation flag 0x80 (six floats). Those groups appear
  consecutively as position, rotation, then scale in each node payload.

  nintoolbox checks OMO magic, complete node and frame tables, an even
  frame_size, recognized enabled-channel flag combinations, and every
  node's computed interpolation span within EOF. It permits zero-sized
  channel groups. The semantic mapping from per-frame u16 keys to bone
  channels is not reconstructed by its text decoder; this schema exposes
  the key words without inventing that mapping.
seq:
  - id: magic
    contents: "OMO "
  - id: version_major
    type: u2
  - id: version_minor
    type: u2
  - id: header_flags
    type: u4
  - id: unknown_0c
    type: u2
    doc: Header control halfword printed by the decoder as unk1.
  - id: bone_count
    type: u2
    doc: Number of 16-byte bone-node descriptors.
  - id: frame_count
    type: u2
    doc: Number of frame-key rows.
  - id: frame_size
    type: u2
    doc: Byte length of each frame-key row; decoder requires it even.
  - id: node_offset
    type: u4
    doc: Absolute offset of the bone-node table.
  - id: inter_offset
    type: u4
    doc: Base added to each node's interpolation-relative offset.
  - id: key_offset
    type: u4
    doc: Absolute offset of the shared frame-key rows.
instances:
  nodes:
    type: node_t
    repeat: expr
    repeat-expr: bone_count
    pos: node_offset
  frames:
    pos: key_offset
    type: frame_t(frame_size / 2)
    repeat: expr
    repeat-expr: frame_count
    doc: Consecutive rows of big-endian u16 key words.
types:
  node_t:
    seq:
      - id: flags
        type: u4
        doc: Presence and channel-mode bits described in the format doc.
      - id: hash
        type: u4
        doc: Bone identifier hash.
      - id: inter_rel_offset
        type: u4
        doc: Offset of interpolation floats relative to header inter_offset.
      - id: node_key_offset
        type: s4
        doc: Printed by decoder but not used to locate shared frame-key rows.
    instances:
      has_position:
        value: (flags & 0x01000000) != 0
      has_rotation:
        value: (flags & 0x02000000) != 0
      has_scale:
        value: (flags & 0x04000000) != 0
      position_float_count:
        value: 'has_position ? ((flags & 0x00200000) == 0x00200000 ? 3 : ((flags & 0x00080000) == 0x00080000 ? 6 : 0)) : 0'
      rotation_float_count:
        value: 'has_rotation ? ((flags & 0xf000) == 0x7000 ? 3 : ((flags & 0xf000) == 0x6000 ? 4 : ((flags & 0xf000) == 0x5000 ? 6 : 0))) : 0'
      scale_float_count:
        value: 'has_scale ? ((flags & 0xf00) == 0x200 or (flags & 0xf00) == 0x300 ? 3 : ((flags & 0xf0) == 0x80 ? 6 : 0)) : 0'
      interpolation_float_count:
        value: position_float_count + rotation_float_count + scale_float_count
      interpolation:
        io: _root._io
        pos: _root.inter_offset + inter_rel_offset
        type: f4
        repeat: expr
        repeat-expr: interpolation_float_count
        doc: Position, rotation, then scale floats selected by node flags.
  frame_t:
    params:
      - id: word_count
        type: u2
    seq:
      - id: keys
        type: u2
        repeat: expr
        repeat-expr: word_count
