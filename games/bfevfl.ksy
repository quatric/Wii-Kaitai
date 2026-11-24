meta:
  id: bfevfl
  title: Nintendo event flow (.bfevfl)
  file-extension: bfevfl
  endian: le
doc: |
  "BFEVFL\0\0", versions 0x0300 / 0x0400 (BotW, TotK, Link's Awakening, Switch 2
  Zelda). Every pointer is a 64-bit absolute file offset; strings are pascal
  (u16 length, bytes, NUL). After the zeldamods "evfl" library.
seq:
  - id: magic
    contents: ["BFEVFL", 0, 0]
  - id: version
    type: u2
  - id: unk0a
    type: u1
  - id: unk0b
    type: u1
  - id: bom
    type: u2
    doc: 0xFEFF.
  - id: alignment_shift
    type: u1
  - id: unk0f
    type: u1
  - id: name_offset
    type: u4
  - id: relocated
    type: u2
  - id: first_block
    type: u2
  - id: relocation_table
    type: u4
  - id: file_size
    type: u4
  - id: flowchart_count
    type: u2
    doc: 0 or 1.
  - id: timeline_count
    type: u2
    doc: 0 or 1.
  - id: unk24
    type: u4
  - id: flowchart_ptr_array
    type: u8
  - id: flowchart_dic
    type: u8
  - id: timeline_ptr_array
    type: u8
  - id: timeline_dic
    type: u8
types:
  flowchart:
    seq:
      - id: magic
        contents: EVFL
      - id: string_pool
        type: u4
      - id: unk8
        type: u4
      - id: unkc
        type: u4
      - id: actor_count
        type: u2
      - id: action_count
        type: u2
      - id: query_count
        type: u2
      - id: event_count
        type: u2
      - id: entry_point_count
        type: u2
      - id: unk1a
        size: 6
      - id: name
        type: u8
      - id: actors
        type: u8
      - id: events
        type: u8
      - id: entry_point_dic
        type: u8
      - id: entry_point_array
        type: u8
  actor:
    seq:
      - id: name
        type: u8
      - id: sub_name
        type: u8
      - id: argument_name
        type: u8
      - id: actions
        type: u8
      - id: queries
        type: u8
      - id: params
        type: u8
      - id: action_count
        type: u2
      - id: query_count
        type: u2
      - id: argument_entry_point
        type: u2
      - id: concurrent_clips
        type: u2
  event_head:
    doc: 0x30 bytes (0x28 in version 0x0300).
    seq:
      - id: name
        type: u8
      - id: type
        type: u1
        enum: event_type
      - id: unk
        type: u1
  entry_point:
    seq:
      - id: sub_flow_indices
        type: u8
      - id: variable_dic
        type: u8
      - id: variable_defs
        type: u8
      - id: sub_flow_count
        type: u2
      - id: def_count
        type: u2
      - id: main_event
        type: u2
      - id: unk
        type: u2
enums:
  event_type:
    0: action
    1: switch
    2: fork
    3: join
    4: sub_flow
    5: sub_flow_switch
    6: return
