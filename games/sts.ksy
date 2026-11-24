meta:
  id: sts
  title: Alfa System .sts DSP voice
  file-extension: sts
  endian: be
doc: |
  Castle of Shikigami III (Wii). Mono data starts at 0x70, stereo at 0x50;
  every further channel is a 0x2e-byte block followed by its ADPCM data.
seq:
  - id: size_without_word
    type: u4
  - id: unk4
    size: 4
  - id: channels_minus_one
    type: u1
  - id: unk9
    size: 3
  - id: sample_rate
    type: u2
  - id: unk0e
    size: 0x0c
  - id: bytes_per_channel
    type: u4
  - id: unk1e
    size: 0
  - id: coefs
    type: s2
    repeat: expr
    repeat-expr: 16
  - id: unk3e
    size: 4
  - id: hist1
    type: s2
  - id: hist2
    type: s2
  - id: rest
    size-eos: true
