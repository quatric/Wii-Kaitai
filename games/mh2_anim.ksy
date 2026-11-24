meta:
  id: mh2_anim
  title: Rockstar Leeds ANPK animation pack (Manhunt 2)
  file-extension: ifp
  endian: be
doc: |
  Per animation: "NAME" {u32 length, name}, u32 bone count, u32 chunk size, f32
  duration; per bone "SEQT" {u16 bone id, u8 frame type, u16 frame count, u16
  start time (/2048*30)}; type 3 adds four s16 (/2048); per frame u16 time (only
  when start time is 0, not for the first type-3 frame), 4 x s16 quaternion
  (/4096) for types 1-3, 3 x s16 position (/2048) for types 2-3; each bone ends
  with an f32 last-frame time. Then {u32 header size, u32, u32 entry size, u32
  entry count} and event entries. Per-bone frame bodies depend on the frame type
  and are modelled as `bone`.
seq:
  - id: magic
    contents: ANPK
  - id: animation_count
    type: u4
  - id: animations
    type: animation
    repeat: expr
    repeat-expr: animation_count
types:
  animation:
    seq:
      - id: name_tag
        contents: NAME
      - id: name_length
        type: u4
      - id: name
        size: name_length
        type: strz
        encoding: ASCII
      - id: name_pad
        size: (-name_length) % 4
      - id: bone_count
        type: u4
      - id: chunk_size
        type: u4
      - id: duration
        type: f4
      - id: bones
        type: bone
        repeat: expr
        repeat-expr: bone_count
      - id: event_header_size
        type: u4
      - id: event_unk
        type: u4
      - id: event_entry_size
        type: u4
      - id: event_count
        type: u4
      - id: events
        size: event_entry_size
        repeat: expr
        repeat-expr: event_count
  bone:
    seq:
      - id: seqt
        contents: SEQT
      - id: bone_id
        type: u2
      - id: frame_type
        type: u1
      - id: frame_count
        type: u2
      - id: start_time
        type: u2
      - id: direction
        type: s2
        repeat: expr
        repeat-expr: 4
        if: frame_type == 3
      - id: frames
        type: frame(frame_type, start_time, _index)
        repeat: expr
        repeat-expr: frame_count
      - id: last_frame_time
        type: f4
  frame:
    params:
      - id: frame_type
        type: u1
      - id: start_time
        type: u2
      - id: index
        type: s4
    seq:
      - id: time
        type: u2
        if: start_time == 0 and not (frame_type == 3 and index == 0)
      - id: rotation
        type: s2
        repeat: expr
        repeat-expr: 4
      - id: position
        type: s2
        repeat: expr
        repeat-expr: 3
        if: frame_type >= 2
