meta:
  id: smashtsqb
  endian: le
  title: Super Smash Bros. 4 sound sequence archive (SQB)
doc: |
  Super Smash Bros. 4 sound sequence archive (.sqb), per
  lib-smashtsqb.c (ported from KillzXGaming/Smash-Forge SQB.cs).
  Sequence structure only; no audio-stream decoding.
seq:
  - id: magic
    contents: [0x53, 0x51, 0x42, 0x00]
  - id: unk1
    type: s2
  - id: unk2
    type: s2
  - id: num_sequences
    type: s4
  - id: sequence_data_offset
    type: s4
  - id: sequence_offsets
    type: s4
    repeat: expr
    repeat-expr: num_sequences
    doc: Relative to 0x10 + sequence_data_offset; -1 means empty.
types:
  sequence_t:
    seq:
      - id: unk1
        type: s2
      - id: num_events
        type: s2
      - id: unk2
        type: s2
      - id: unk3
        type: s2
      - id: events
        type: event_t
        repeat: expr
        repeat-expr: num_events
  event_t:
    seq:
      - id: hash
        type: u4
      - id: kind
        type: s2
      - id: frame
        type: s2
      - id: unk1
        type: s2
      - id: unk2
        type: s2
      - id: unk3
        type: s2
      - id: unk4
        type: s2
