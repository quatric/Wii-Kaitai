meta:
  id: kcs
  title: Spyro Dawn of the Dragon streamed animation buffer (.KCS)
  file-extension: kcs
  endian: be
doc: |
  Run of chunks {u32 size, u32 size, u32 type, u32 count, ...} separated by 0xcd /
  zero padding; the buffer is padded to a multiple of 128 KiB. Type 0 is a
  skeleton pose: {u32 0, u32 0, f32 duration, u32 0, u32 0} after the 16-byte
  head, then count records of 36 bytes {u32 bone id, u32 0, f32 quaternion x y z
  w, f32 position x y z} from offset 0x24. Type 3 holds count records of 40 bytes
  from offset 0x14.
seq:
  - id: size_a
    type: u4
  - id: size_b
    type: u4
  - id: type
    type: u4
  - id: count
    type: u4
  - id: rest
    size-eos: true
types:
  pose_header:
    seq:
      - id: zero0
        type: u4
      - id: zero1
        type: u4
      - id: duration
        type: f4
      - id: zero2
        type: u4
      - id: zero3
        type: u4
  pose_record:
    seq:
      - id: bone_id
        type: u4
      - id: zero
        type: u4
      - id: quaternion
        type: f4
        repeat: expr
        repeat-expr: 4
      - id: position
        type: f4
        repeat: expr
        repeat-expr: 3
