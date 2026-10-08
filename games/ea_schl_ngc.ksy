meta:
  id: ea_schl_ngc
  title: Electronic Arts GameCube/Wii SCHl stream (.ngc / .fcd)
  file-extension: ngc
  endian: le
doc: |
  Electronic Arts `.ngc` streams (Tiger Woods PGA Tour movies and music, NBA
  Live `.fcd` speech): a chain of little-endian blocks `{tag, u4 size
  including the 8-byte header}` -- `SCHl` (header), `SCCl`, `SCDl` (data) and
  `SCEl` (end). Video (`MVhd`, `m6PV`) blocks are skipped by nintoolbox. NBA
  Live `.fcd` files are several `SCHl..SCEl` streams padded to 0x100.

  The `SCHl` body begins with a 4-character platform tag (e.g. `GSTR`) and then
  patch elements after a `0xFD` marker, each `{u1 id, u1 len, big-endian
  value}` terminated by `0xFF`: `0x80` revision, `0x82` channels, `0x83` codec,
  `0x84` sample rate, `0x85` samples. Each `SCDl` holds one ADPCM "R3" packet
  (big-endian): `u4 samples`, `u4 channel_offset[ch]` (relative to packet
  start + 4 * (ch + 1)), then per channel 28-sample frames -- byte `0xEE` = raw
  `{s2 cur, s2 prev, 28 * s2}`, otherwise `{u1 coef << 4 | shift, 14 nibble
  bytes}`.
seq:
  - id: blocks
    type: block
    repeat: eos
types:
  block:
    seq:
      - id: tag
        type: str
        size: 4
        encoding: ASCII
      - id: size
        type: u4
      - id: body
        size: size - 8
