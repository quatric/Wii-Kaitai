meta:
  id: konami_vas
  title: Konami Wii streaming bank (.vas)
  file-extension: vas
  endian: be
doc: |
  Konami Wii streaming bank `.vas` (Jikkyou Powerful Pro Yakyuu `strbgm.vas`),
  built from 0x800 pages: page 0 is the file header, then every stream is one
  header page followed by its data padded to 0x800. The stream header page is
  `{u32 interleaved data bytes, u32 rate}` plus one 0x40-byte DSP channel header
  per channel at `0x80 + 0x40 * ch` (`{u16 loop, u16 fmt, u32 start, u32 end,
  u32 cur, 16 s16 coefs, ...}`); the data holds the channels interleaved in
  0x100-byte blocks.
seq:
  - id: reserved0
    size: 4
  - id: num_pages_minus_1
    type: u4
  - id: num_streams
    type: u4
