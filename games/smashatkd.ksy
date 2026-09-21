meta:
  id: smashatkd
  endian: be
  title: Super Smash Bros. 4 attack/subaction frame data (ATKD)
doc: |
  Super Smash Bros. 4 attack/subaction hitbox frame data, per
  lib-smashatkd.c (ported from KillzXGaming/Smash-Forge ATKD.cs).
seq:
  - id: magic
    contents: "ATKD"
  - id: num_entries
    type: s4
  - id: common_subactions
    type: u4
  - id: unique_subactions
    type: u4
  - id: entries
    type: entry_t
    repeat: expr
    repeat-expr: num_entries
types:
  entry_t:
    seq:
      - id: subaction
        type: u2
      - id: padding
        type: u2
      - id: start_frame
        type: u2
      - id: last_frame
        type: u2
      - id: x_min
        type: f4
      - id: x_max
        type: f4
      - id: y_min
        type: f4
      - id: y_max
        type: f4
