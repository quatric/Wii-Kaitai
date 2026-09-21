meta:
  id: sadl
  endian: le
  title: Level-5 SADL audio stream
doc: |
  Level-5 "SADL" audio stream, ported from DecodeSADL_WAV() in
  lib-sadl.c. Only the fields the reference decoder actually reads
  are modeled; the rest of the 0x100-byte header is left raw.
seq:
  - id: magic
    contents: "SADL"
  - id: unknown_04
    size: 0x32 - 4
  - id: channels
    type: u1
    doc: 0 is treated as 1 channel.
  - id: coding
    type: u1
    doc: (coding & 6) == 4 selects 32728 Hz, else 16364 Hz.
  - id: unknown_34
    size: 0x40 - 0x34
  - id: file_size
    type: u4
  - id: unknown_44
    size: 0x100 - 0x44
  - id: data
    size-eos: true
