meta:
  id: betp_trace
  title: BETP dance trace path (_trace.bin)
  file-extension: bin
  endian: be
doc: |
  `BETP` dance trace paths (The Smurfs: Dance Party `*_trace.bin`, Wii). A
  negative move id marks the stroke direction.
seq:
  - id: magic
    contents: BETP
  - id: num_points
    type: u4
  - id: screen_width
    type: u4
  - id: screen_height
    type: u4
  - id: points
    type: point
    repeat: expr
    repeat-expr: num_points
types:
  point:
    seq:
      - id: move_id
        type: s4
      - id: x
        type: u2
      - id: y
        type: u2
