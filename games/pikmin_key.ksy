meta:
  id: pikmin_key
  title: Pikmin 1 animation key table (.key / .bin)
  file-extension: key
  endian: be
doc: |
  {s32 version, s32 count}, a tagged parameter list ({u24 id, u8 size} + value,
  -1 ends), then per animation a length-prefixed name, tagged parameters
  ("p00" flags, "spd" speed), anim key frames, info keys (version >= 1) and
  event keys.
seq:
  - id: version
    type: s4
  - id: count
    type: s4
  - id: parameters
    type: param
    repeat: until
    repeat-until: _.is_end
types:
  param:
    seq:
      - id: head
        type: u4
      - id: value
        size: head & 0xff
        if: head != 0xffffffff
    instances:
      is_end:
        value: head == 0xffffffff
      id:
        value: head >> 8
