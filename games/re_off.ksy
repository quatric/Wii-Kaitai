meta:
  id: re_off
  title: Resident Evil GameCube remake section list (.emg, .emd)
  endian: be
doc: |
  Resident Evil (GameCube remake, Resident Evil Archives) `*.emg` / `*.emd`. The
  file starts with a list of ascending, 0x20-aligned section offsets (zero
  terminated, the rest of the header up to the first section is zero); the last
  section runs to the end of the file, or the final offset equals the file size.
seq:
  - id: offsets
    type: u4
    repeat: until
    repeat-until: _ == 0
