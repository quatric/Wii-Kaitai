meta:
  id: wwrsc
  endian: be
  title: Wario World resource container (GameCube, .rsc)
doc: |
  Wario World resource container, per lib-wwrsc.h (re-implemented
  from KillzXGaming/MdlConverter's GCNLibrary/WarioWorld). 0x20 bytes
  of unknown header words followed by a 32-byte-aligned linked list of resources.
  Per-resource-type model/animation/collision payloads are variable-
  layout and not expanded here.

  nintoolbox validates each node's type (0..32), payload range, and next
  pointer. A non-final `next_offset` must move forward, remain within EOF, and
  be 32-byte aligned; the final zero pointer is accepted only when its member
  reaches within 64 bytes of EOF. The chain is capped at 100,000 resources.
seq:
  - id: unknown_header
    size: 0x20
    doc: Twenty unknown bytes preserved verbatim by the reader/writer.
  - id: resources
    type: resource_t
    repeat: eos
types:
  resource_t:
    seq:
      - id: resource_type
        type: u4
        enum: ww_rtype_t
        doc: Resource kind used to choose an extraction filename extension.
      - id: size
        type: u4
        doc: Byte length of the resource payload following this 32-byte header.
      - id: next_offset
        type: u4
        doc: Absolute offset of the next aligned resource header, or zero for
          the final resource.
      - id: reserved
        size: 20
        doc: Unknown per-resource header bytes at offsets 0x0c..0x1f.
      - id: payload
        size: size
        doc: Format-specific resource body.
      - id: padding
        size: (32 - (size % 32)) % 32
        doc: Alignment bytes in the canonical contiguous layout. The reader
          follows `next_offset`, so files may use larger gaps.
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
