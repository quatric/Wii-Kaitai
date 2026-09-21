meta:
  id: wii_wibn
  endian: be
  title: Wii save-game banner (WIBN)
doc: |
  Wii save-game banner, per lib-wii-banner.h. Lives at the start of
  a save's decrypted banner.bin/data.bin. Icon count is not stored:
  it follows from the file size, and trailing all-zero frames are
  padding rather than real animation steps.

  This is the format shown in the Wii System Menu's save-data management
  screen, distinct from (though visually similar in layout to) the
  IMET-headed channel banner in opening.bnr -- a WIBN has no IMD5/IMET
  wrapper of its own and sits directly at the front of the save's banner
  file once decrypted. wiibrew.org's Savegame Files page documents the
  same header at the same offsets, which the fields below cross-check
  against.
doc-ref: 'https://wiibrew.org/wiki/Savegame_Files'
seq:
  - id: magic
    contents: "WIBN"
  - id: flags
    type: u4
    doc: |
      Bit 0 (0x01) marks the save as not copyable to/from an SD card or
      NAND via the System Menu's normal copy flow. wiibrew additionally
      documents bit 4 (0x10) as making the icon animation "bounce"
      back and forth between frame 0 and the last frame instead of
      looping forward and cutting back to frame 0.
  - id: anim_speed
    type: u2
    doc: |
      Frame hold time in Wii Menu animation ticks: 0 means the icon does
      not animate (only the first frame is ever shown, and `icons` in
      that case should hold exactly one frame), with 1-3 giving
      progressively slower per-frame delays per wiibrew.
  - id: reserved
    size: 22
  - id: title
    type: str
    size: 64
    encoding: UTF-16BE
    doc: |
      Save title as shown on the System Menu's data management screen,
      NUL-padded to the full 64 bytes (32 UTF-16 code units) rather than
      only NUL-terminated.
  - id: subtitle
    type: str
    size: 64
    encoding: UTF-16BE
    doc: Second line of the save's title, shown beneath `title` in the same screen.
  - id: banner
    size: 192 * 64 * 2
    doc: |
      192x64 RGB5A3, GameCube 4x4 tile order -- the same pixel format and
      tiling TPL/TEX0 textures use elsewhere in this repo's NW4R types,
      reused here without a texture header since the dimensions and
      format are fixed by the save-banner spec rather than declared
      in-file.
  - id: icons
    size-eos: true
    doc: |
      1 to 8 frames of 48x48 RGB5A3, same tile order as `banner`; the
      frame count is never stored explicitly and instead follows from
      how many whole 48*48*2-byte frames fit between here and EOF. A
      one-frame save (the common case, `anim_speed` 0) is
      indistinguishable at the byte level from a multi-frame save whose
      later frames all happen to be identical -- only `anim_speed` being
      nonzero indicates the icon is meant to actually animate.
