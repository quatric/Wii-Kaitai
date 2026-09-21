meta:
  id: wwrsc
  endian: be
  title: Wario World resource container (GameCube, .rsc)
doc: |
  Wario World resource container, per lib-wwrsc.h (re-implemented
  from KillzXGaming/MdlConverter's GCNLibrary/WarioWorld). 0x20 bytes
  of unknown header words followed by a linked list of resources.
  Per-resource-type model/animation/collision payloads are variable-
  layout and not expanded here.
seq:
  - id: unknown_header
    size: 0x20
  - id: resources
    type: resource_t
    repeat: eos
types:
  resource_t:
    seq:
      - id: resource_type
        type: u4
        enum: ww_rtype_t
      - id: size
        type: u4
      - id: next_offset
        type: u4
      - id: reserved
        size: 20
      - id: payload
        size: size
      - id: padding
        size: (32 - (size % 32)) % 32
enums:
  ww_rtype_t:
    0: static_model
    1: texture_container
    2: skel_animation
    3: map_model
    4: collision
    5: rigged_model
    6: map_params
    8: lighting
    9: spawns
    10: animation
    11: special_collision
    14: message
