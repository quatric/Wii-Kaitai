meta:
  id: smashomo
  endian: be
  title: Super Smash Bros. 4 object-motion animation (OMO)
doc: |
  Super Smash Bros. 4 object-motion skeletal animation (.omo), per
  lib-smashomo.c (ported from KillzXGaming/Smash-Forge OMO.cs). The
  per-bone interpolation payload pointed to by `inter_off` is a
  flags-dependent variable-size record and is not expanded here.
seq:
  - id: magic
    contents: "OMO "
  - id: unknown_04
    size: 6
  - id: bone_count
    type: u2
  - id: frame_count
    type: u2
  - id: frame_size
    type: u2
  - id: node_offset
    type: u4
  - id: inter_offset
    type: u4
  - id: key_offset
    type: u4
instances:
  nodes:
    type: node_t
    repeat: expr
    repeat-expr: bone_count
    pos: node_offset
types:
  node_t:
    seq:
      - id: flags
        type: u4
      - id: unknown_04
        type: u4
      - id: inter_rel_offset
        type: u4
      - id: unknown_0c
        type: u4
