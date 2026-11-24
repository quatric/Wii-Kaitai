meta:
  id: pikmin_jam
  title: JAudio1 sequence (.jam)
  file-extension: jam
doc: |
  Pikmin 1 pikiseq.arc and other first-generation JAudio games. Byte code
  interpreted like the game's sequencer (Jam_SeqmainNote / Cmd_Process): notes,
  waits, registers, conditions, calls, loops and child tracks (OpenTrack).
  Every JAM begins with an "opentrack" (0xC1) preamble. pikiseq.arc has no
  header: 17 JAMs back to back (220,992 bytes), the offsets live in pikiseq.hed
  inside the DOL.
seq:
  - id: opentrack
    contents: [0xc1]
  - id: byte_code
    size-eos: true
