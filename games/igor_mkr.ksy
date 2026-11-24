meta:
  id: igor_mkr
  title: Igor voice-over cue markers (.mkr)
  file-extension: mkr
  endian: le
doc: |
  Igor: The Game voice-over cue markers (`.mkr` next to the `audio/playvo/*.fsb`
  banks). The 4-byte files hold count 0.
seq:
  - id: count
    type: u4
  - id: markers
    type: marker
    repeat: expr
    repeat-expr: count
types:
  marker:
    seq:
      - id: time_seconds
        type: f4
      - id: len_name
        type: u4
      - id: name
        type: str
        size: len_name
        encoding: ASCII
