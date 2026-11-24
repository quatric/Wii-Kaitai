meta:
  id: myspd
  title: Punchers Impact .myspd (U-Sing)
  file-extension: myspd
  endian: be
doc: |
  Punchers Impact `.myspd` (U-Sing, Wii). Two channels of plain IMA ADPCM (low
  nibble first, history 0, step index 0), one after the other; file size is
  exactly `0x20 + 2 * channel size`. Stereo.
seq:
  - id: len_channel
    type: u4
  - id: sample_rate
    type: u4
  - id: padding
    size: 0x18
  - id: left
    size: len_channel
  - id: right
    size: len_channel
