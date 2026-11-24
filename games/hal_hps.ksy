meta:
  id: hal_hps
  title: HAL Laboratory streamed music (.hps)
  file-extension: hps
  endian: be
doc: |
  HAL Laboratory `.hps` streamed music (Super Smash Bros. Brawl/Melee, Kirby).
  Per channel at 0x10 a 0x38-byte DSP-ADPCM channel info (a standard DSP header
  from offset 0x0C: loop/format, start/end/current nibble addresses, 16
  coefficients, gain, initial ps and history). Audio starts at 0x80 in blocks
  `{u32 size, u32 last sample, u32 next block offset, per-channel ps/history,
  padding to 0x20}` whose payload is split evenly between the channels.
seq:
  - id: magic
    contents: ' HALPST'
  - id: zero
    size: 1
  - id: sample_rate
    type: u4
  - id: num_channels
    type: u4
  - id: channel_infos
    size: 0x38
    repeat: expr
    repeat-expr: num_channels
