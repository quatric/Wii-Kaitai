meta:
  id: smashatkd
  endian: be
  title: Super Smash Bros. 4 attack/subaction frame data (ATKD)
doc: |
  Super Smash Bros. 4 attack/subaction hitbox frame data, per
  lib-smashatkd.c (ported from KillzXGaming/Smash-Forge ATKD.cs).

  The 16-byte header is followed immediately by num_entries 24-byte
  records. Each record associates a subaction ID and start/last frame
  numbers with a 2D rectangular extent (x_min, x_max,
  y_min, y_max) stored as big-endian floats. The source does not establish
  coordinate units or whether the endpoint frame is inclusive, so those
  details should not be inferred from the field names.

  nintoolbox recognizes ATKD magic, an entry count at most 1000000,
  and an exact file length of `16 + 24 * num_entries`. A zero-entry
  file is accepted. The common/unique subaction counts are reported
  but not cross-checked against individual record IDs. The two-byte
  per-record padding is skipped without validation.
seq:
  - id: magic
    contents: "ATKD"
  - id: num_entries
    type: u4
    doc: Number of 24-byte records; reader accepts 0 through 1000000.
  - id: common_subactions
    type: u4
    doc: Header's reported common-subaction count, not independently verified.
  - id: unique_subactions
    type: u4
    doc: Header's reported unique-subaction count, not independently verified.
  - id: entries
    type: entry_t
    repeat: expr
    repeat-expr: num_entries
types:
  entry_t:
    seq:
      - id: subaction
        type: u2
        doc: Subaction identifier associated with this rectangle.
      - id: padding
        type: u2
        doc: Skipped halfword; decoder does not require a particular value.
      - id: start_frame
        type: u2
        doc: First frame number reported for this record.
      - id: last_frame
        type: u2
        doc: Last frame number reported for this record.
      - id: x_min
        type: f4
        doc: Minimum x coordinate of the recorded rectangle.
      - id: x_max
        type: f4
        doc: Maximum x coordinate of the recorded rectangle.
      - id: y_min
        type: f4
        doc: Minimum y coordinate of the recorded rectangle.
      - id: y_max
        type: f4
        doc: Maximum y coordinate of the recorded rectangle.
