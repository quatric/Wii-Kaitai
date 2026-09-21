meta:
  id: wii_wibn
  endian: be
  title: Wii save-game banner (WIBN)
doc: |
  Wii save-game banner, per lib-wii-banner.h. Lives at the start of
  a save's decrypted banner.bin/data.bin. Icon count is not stored:
  it follows from the file size, and trailing all-zero frames are
  padding rather than real animation steps.
seq:
  - id: magic
    contents: "WIBN"
  - id: flags
    type: u4
    doc: Bit 0 (0x01) marks the save as not copyable.
  - id: anim_speed
    type: u2
  - id: reserved
    size: 22
  - id: title
    type: str
    size: 64
    encoding: UTF-16BE
  - id: subtitle
    type: str
    size: 64
    encoding: UTF-16BE
  - id: banner
    size: 192 * 64 * 2
    doc: 192x64 RGB5A3, GameCube 4x4 tile order.
  - id: icons
    size-eos: true
    doc: 1..8 frames of 48x48 RGB5A3, same tile order; count follows from file size.
