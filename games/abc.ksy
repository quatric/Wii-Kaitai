meta:
  id: abc
  title: Sumo Digital .abc audio library (SEGA All-Stars Racing)
  file-extension: abc
  endian: be
doc: Complete DSP-ADPCM files back to back, each (0x60-byte header + (nibbles + 1) / 2 bytes) followed by 1..0x100 padding bytes up to the next multiple of 0x100.
seq:
  - id: streams
    type: stream
    repeat: eos
types:
  stream:
    seq:
      - id: sample_count
        type: u4
      - id: nibble_count
        type: u4
      - id: rate
        type: u4
      - id: header_rest
        size: 0x60 - 12
      - id: data
        size: (nibble_count + 1) / 2
      - id: pad
        size: 0x100 - ((0x60 + (nibble_count + 1) / 2) % 0x100)
