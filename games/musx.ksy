meta:
  id: musx
  title: Eurocom MUSX sound bank (Wii SBNK form)
  endian: le
doc: |
  Dead Space Extraction File_<region>.000. "MUSX", u32 version 10 @8, platform
  "WII_" @0x10; an "SBNK" block at 0x800 (u32 0x12 version; the table block at
  0x810 is big endian) whose table 5 (count @+0x20, offset @+0x24 from there +
  0x24) lists sounds as 0x1c-byte records {u32 id, s32 samples, s32 loop start
  (-1 none), u16 rate, u8 codec, u8 channels, u32 data offset (+ data base @
  +0x3c), u32 size, ...}. Codec 0x13 (DSP-ADPCM): one block of size / channels
  bytes per channel, each starting with a 0x40-byte "NGCA" header (u32 size, u32
  2, coefficients from +0xc, gain +0x2c, initial ps +0x2e, history +0x30).
seq:
  - id: magic
    contents: MUSX
  - id: unk4
    size: 4
  - id: version
    type: u4
    doc: 10.
  - id: unk0c
    size: 4
  - id: platform
    contents: WII_
