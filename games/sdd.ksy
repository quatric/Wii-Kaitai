meta:
  id: sdd
  title: Piglet's Big Game sound bank (.sdd)
  file-extension: sdd
  endian: le
doc: |
  Piglet's Big Game sound bank (`DSBH` + `DSBD`, little endian even on
  GameCube). Entries start at 0x20 (`{name\0, codec u8 (1 DSP, 2 PCM RIFF, 3
  PS-ADPCM), bits, channels u8, rate u32, sound offset u32, sound size u32}`); the
  data block `DSBD` is at the header size, sounds at +0x20. DSP entries start with
  a 0x60-byte DSP header; PCM entries are RIFF WAVE. Entries have variable-length
  names, so only the header is modelled.
seq:
  - id: magic
    contents: DSBH
  - id: header_size
    type: u4
