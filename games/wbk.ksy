meta:
  id: wbk
  title: Treyarch NSLB sound bank (.wbk)
  file-extension: wbk
  endian: le
doc: |
  Kung Fu Panda, Call of Duty 3 (Wii). Info entry: rate u16, codec u8
  (0x22 = DSP), flags u8 (1 streamed, 2 loops), channel mask u8, then
  per-channel 0x30-byte records holding DSP coefficients.
seq:
  - id: magic
    contents: NSLB
  - id: version
    type: u2
  - id: pad
    size: 10
  - id: sound_count
    type: u4
  - id: unk14
    size: 4
  - id: name_table_offset
    type: u4
  - id: sound_table_offset
    type: u4
  - id: unk20
    size: 4
  - id: info_offset
    type: u4
  - id: unk28
    size: 4
  - id: strings_offset
    type: u4
  - id: unk30
    size: 4
  - id: in_bank_data_offset
    type: u4
  - id: unk38
    size: 4
  - id: streamed_data_offset
    type: u4
instances:
  name_offsets:
    pos: name_table_offset
    type: u4
    repeat: expr
    repeat-expr: sound_count
  sounds:
    pos: sound_table_offset
    type: sound
    repeat: expr
    repeat-expr: sound_count
types:
  sound:
    seq:
      - id: info_entry_offset
        type: u4
      - id: sound_offset
        type: u4
      - id: sound_size
        type: u4
      - id: samples
        type: u4
