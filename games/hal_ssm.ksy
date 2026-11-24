meta:
  id: hal_ssm
  title: HAL Laboratory GameCube sound bank (.ssm)
  file-extension: ssm
  endian: be
doc: |
  HAL Laboratory GameCube sound bank (Smash Bros. Melee, Kururin Squash!,
  Gashbell; after vgmstream `ngc_ssm.c`). Per channel a 0x40-byte record: loop
  flag s16 at 0 (first channel only is used), loop start nibble at 4, end nibble
  at 8, first nibble at 0xC, 16 DSP coefficients at 0x10, hist1/hist2 at
  0x34/0x36. Offsets are absolute DSP nibbles into the data block (file end -
  data size); the second channel's first nibble is the interleave.
seq:
  - id: len_head
    type: u4
  - id: len_data
    type: u4
  - id: num_subsongs
    type: u4
  - id: id
    type: u4
  - id: subsongs
    type: subsong
    repeat: expr
    repeat-expr: num_subsongs
types:
  subsong:
    seq:
      - id: num_channels
        type: u4
      - id: sample_rate
        type: u4
      - id: channel_records
        size: 0x40
        repeat: expr
        repeat-expr: num_channels
