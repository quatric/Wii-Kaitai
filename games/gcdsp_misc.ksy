meta:
  id: gcdsp_misc
  title: GameCube DSP-ADPCM non-standard wrappers (.lps / KCE .dsp / .ymf)
  endian: be
doc: |
  Rave Master .lps and KCE Japan East .dsp: u32 BE data size @0 (file = size +
  0xe0), 1 @4, 0x10000000 @8, 0 @0xc; standard 0x60-byte DSP header at 0x20,
  mono ADPCM from 0xe0. Yuke's WrestleMania X8 .ymf: 0x180 @0, 3 @8, 0xCCCCCCCC
  @0xc; data start = u32 @0, rate @0xa8, samples @0xdc, coefs @0xae (0x60 per
  channel), stereo with 0x20000-byte interleave.
seq:
  - id: data_size
    type: u4
  - id: one
    type: u4
  - id: marker
    type: u4
  - id: zero
    type: u4
  - id: pad
    size: 0x20 - 0x10
  - id: dsp_header
    size: 0x60
  - id: pad2
    size: 0xe0 - 0x80
  - id: adpcm
    size-eos: true
