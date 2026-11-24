meta:
  id: midi_render
  title: Standard MIDI File (output of the JAudio / m4a sequence converters)
  file-extension: mid
  endian: be
doc: The converters (pikmin_jam, mp2k) emit format-0/1 SMF; division is the sequence's time base.
seq:
  - id: magic
    contents: MThd
  - id: header_length
    type: u4
    doc: 6.
  - id: format
    type: u2
  - id: track_count
    type: u2
  - id: division
    type: u2
  - id: tracks
    type: track
    repeat: expr
    repeat-expr: track_count
types:
  track:
    seq:
      - id: magic
        contents: MTrk
      - id: length
        type: u4
      - id: events
        size: length
