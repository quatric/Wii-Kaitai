meta:
  id: wii_imd5
  endian: be
  title: Wii menu resource IMD5 header
doc: |
  The 0x20-byte header Nintendo puts in front of banner.bin,
  icon.bin and sound.bin (and other Wii menu resources), per
  lib-wii-banner.h. The payload may itself be an "LZ77"-wrapped
  LZ10/LZ11 stream (not modeled here).
seq:
  - id: magic
    contents: "IMD5"
  - id: payload_size
    type: u4
  - id: reserved
    size: 8
  - id: md5
    size: 16
  - id: payload
    size-eos: true
