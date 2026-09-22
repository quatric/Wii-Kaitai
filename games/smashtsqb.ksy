meta:
  id: smashtsqb
  endian: le
  title: Super Smash Bros. 4 sound sequence archive (SQB)
doc: |
  Super Smash Bros. 4 sound sequence archive (.sqb), per
  lib-smashtsqb.c (ported from KillzXGaming/Smash-Forge SQB.cs).
  Each signed sequence-table value is relative to `0x10 +
  sequence_data_offset`; -1 denotes an empty slot. A nonempty sequence
  has an eight-byte header and num_events 16-byte event records. These
  are sound-event references, not encoded audio samples.

  nintoolbox requires at most 100000 sequences, a complete offset table,
  and each nonempty sequence header and event array within EOF. A negative
  offset other than -1 is invalid, as is an event count above 1000000.
  The four unknown event halfwords are retained but not interpreted by
  the text decoder. This schema follows the pointers but does not perform
  all of the reader's bounds checks explicitly.
seq:
  - id: magic
    contents: [0x53, 0x51, 0x42, 0x00]
  - id: unk1
    type: s2
  - id: unk2
    type: s2
  - id: num_sequences
    type: u4
    doc: Number of sequence-reference words following the fixed header.
  - id: sequence_data_offset
    type: u4
    doc: Base offset measured from file position 0x10.
  - id: sequence_refs
    type: sequence_ref
    repeat: expr
    repeat-expr: num_sequences
    doc: Relative offsets, each optionally referring to one sequence.
types:
  sequence_ref:
    seq:
      - id: relative_offset
        type: s4
        doc: -1 is empty; nonnegative values are relative to the data base.
    instances:
      sequence:
        io: _root._io
        pos: 0x10 + _root.sequence_data_offset + relative_offset
        type: sequence_t
        if: relative_offset >= 0
  sequence_t:
    seq:
      - id: unk1
        type: s2
      - id: num_events
        type: u2
        doc: Number of 16-byte event records.
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
        doc: Referenced sound/event identifier hash.
      - id: kind
        type: s2
        doc: Event type value reported by the decoder.
      - id: frame
        type: s2
        doc: Frame at which this event is triggered.
      - id: unk1
        type: s2
      - id: unk2
        type: s2
      - id: unk3
        type: s2
      - id: unk4
        type: s2
