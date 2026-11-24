meta:
  id: dspwrap
  title: Game-specific wrappers around interleaved DSP-ADPCM
  endian: be
doc: |
  One standard 0x60-byte DSP header per channel followed by ADPCM interleaved in
  fixed-size chunks. Variants: Traveller's Tales "IDSP" (.gcm/.idsp: +0x04/+0x08
  version pairs {1,0xc8}, {2,0xd2}, {3,0x12c}; +0x0c interleave), Next Level
  "IDSP" (+0x04 interleave, headers at 0x0c), Procyon "sadb" (.sad: channels u8 at
  +0x32, headers at 0x80, data +0x48, interleave 0x10), Paon "KNON"/"KAST" (.asr:
  stereo, headers at 0x70, data +0x800, interleave 0x10), Reflections "04SW"
  (.xa: two DSP headers at 0x04, data at u32 @0xc4, interleave 0x8000), Capcom
  "DSPW" (.dspw: channels at +0x18, per-channel {header, data} blocks of (size -
  0x20) / channels from 0x20).
seq:
  - id: magic
    size: 4
  - id: rest
    size-eos: true
