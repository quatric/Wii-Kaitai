meta:
  id: uranai_affinity
  title: Today & Tomorrow Channel - etc/affinity.bin (compatibility photo poses)
  application: Today & Tomorrow Channel
  file-extension: bin
  endian: be
doc: |
  Pose data for the group photo shown on the compatibility screen. It plays no part in the
  compatibility rating itself (0x800DDAEC reads only the day's scores).

  Fifteen `(count, offset)` index entries = 3 ratings (0 normal, 1 good, 2 very good) x
  group sizes 2 to 6, entry number `rating * 5 + (size - 2)`. Each block holds `count`
  variants, and each variant is one 124-byte (0x7C) person record for each of the `size`
  people, so every block is exactly `count * size * 124` bytes (checked for all fifteen).
  The console chooses the block by `rating * 0x28 + ...` (0x800DDF40) and a variant with
  the game's RNG, `rand() % count`. Variants per rating: normal 1, good 2, very good 5
  (6 for groups of five). `affinity_eu.bin` is a re-tuned copy for the EU layouts.
seq:
  - id: index
    type: index_entry(_index)
    repeat: expr
    repeat-expr: 15
types:
  index_entry:
    params:
      - id: slot
        type: s4
    seq:
      - id: count
        type: u4
      - id: offset
        type: u4
    instances:
      rating:
        value: slot / 5
      people:
        value: slot % 5 + 2
      variants:
        io: _root._io
        pos: offset
        type: variant(people)
        repeat: expr
        repeat-expr: count
  variant:
    params:
      - id: people
        type: s4
    seq:
      - id: person
        type: person
        repeat: expr
        repeat-expr: people
  person:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
        doc: for example -0.4, 0.0, 2.7
      - id: unknown_0c
        size: 24
      - id: pose
        type: u4
        doc: for example 0x00040064
      - id: motion_slots
        type: u4
        repeat: expr
        repeat-expr: 7
        doc: 0xFFFF0000 marks an unused slot
      - id: unknown_44
        type: u4
      - id: frames
        type: u4
      - id: unknown_4c
        size: 24
      - id: scale_a
        type: f4
        doc: for example 1.2
      - id: scale_b
        type: f4
        doc: for example 6.6
      - id: unknown_6c
        type: u4
      - id: scale_c
        type: f4
        doc: for example 1.0
      - id: unknown_74
        type: u4
      - id: flags
        type: u4
