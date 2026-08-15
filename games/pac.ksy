meta:
  id: pac
  file-extension: pac
  endian: be
  title: Super Smash Bros. Brawl PAC archive
doc: |
  Brawl's flat, uncompressed archive format -- `ARC\0`, one of every
  fighter's, stage's and UI screen's on-disc containers (`FitIke.pac`,
  `FitPikmin.pac`, ...). Unlike SARC or GFA there is no compression and no
  per-entry filename: members are addressed purely by index, and their
  meaning comes from a numeric `type` (BrawlLib's `ARCFileType` enum) plus
  a per-type `index`.

  Layout follows BrawlLib's own struct definitions (`libertyernie/
  BrawlCrate`, `BrawlLib/SSBB/Types/ARC.cs` `ARCHeader`/`ARCFileHeader`):
  a 0x40-byte archive header followed by `num_entries` 0x20-byte entry
  headers, each immediately followed by that entry's raw data. An entry's
  data always starts at `header_offset + 0x20`, and the next entry header
  sits at `round_up(data_offset + size, 0x20)` -- 32-byte alignment from
  the start of the file, since the 0x40-byte archive header is itself
  32-aligned.

  Verified field-by-field against 17 real retail files from Super Smash
  Bros. Brawl (every `Fit*.pac`, `Fit*MotionEtc.pac` and `Fit*Final.pac`
  under a real disc's `fighter/` folder, `FitCaptain.pac` through
  `FitRobotMotionEtc.pac`, all parsed end-to-end -- every entry's
  `data`/`pad` walk landing exactly on the next 0x20-aligned entry header,
  through files with as many as 13 entries): `magic` reads `ARC\0`,
  `version` is `0x0101` on every one, and ordinary character files' first
  entry decodes as `type` 1 (`MiscData`, Brawl's per-character "moveset"
  block).

  Two assumptions that looked safe from a single sample turned out not to
  hold across the corpus:

  * **`name` is not a fixed template string.** `FitIke.pac`,
    `FitGanon.pac`, `FitPikmin.pac`, `FitPurin.pac` and `FitPeach.pac`
    itself all carry `FitPeach`, but `FitDonkey.pac` and `FitRobot.pac`
    carry `FitSonic`, and every `*MotionEtc.pac`/`*Final.pac` carries a
    name matching *that* file's own character and suffix (e.g.
    `FitSonicFinal`, `FitPeachMotionEtc`). So this is closer to "whichever
    template BrawlLib's tooling started the edit from" than a single
    universal placeholder -- still not derived from the file's own
    identity, but not the constant the type=1/SakuraiArchive assumption
    below implied either.
  * **The first entry is not always raw `MiscData`.** That holds for
    ordinary fighter files, but every `*Final.pac` (Final Smash
    transformations -- Giga Bowser, Sonic's Super form, etc.) instead
    packs each entry's `data` as a nested `bres` (BRRES) resource, and
    `FitPeachFinal.pac`'s *second* entry is a nested `ARC\0` -- a whole
    PAC archive embedded inside another PAC archive's entry. `type` for
    that first entry varies accordingly (`3`/Texture on
    `FitDonkeyFinal.pac`, `1`/MiscData on `FitPeachFinal.pac`) rather than
    being a fixed `1`.
seq:
  - id: magic
    contents: [0x41, 0x52, 0x43, 0x00]
  - id: version
    contents: [0x01, 0x01]
    doc: |
      Stored as two identical bytes rather than a real big/little-endian
      u2, so which byte order you read it in never actually matters.
  - id: num_entries
    type: u2
  - id: reserved1
    type: u4
  - id: reserved2
    type: u4
  - id: name
    type: strz
    size: 48
    encoding: ASCII
    doc: |
      The archive's embedded name. In every retail sample checked this is
      `FitPeach` no matter which fighter the file actually is -- a
      template string BrawlLib's own tooling left behind rather than
      per-file metadata.
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: type
        type: u2
        enum: file_type
        doc: BrawlLib's `ARCFileType` enum.
      - id: index
        type: u2
      - id: len_data
        type: u4
        doc: Length of this entry's data, immediately following this header.
      - id: group_index
        type: u1
      - id: padding
        type: u1
      - id: redirect_index
        type: s2
        doc: |
          `-1` (0xffff) when this entry owns its data outright. A
          non-negative value means this entry's data is shared with (an
          alias of) another entry's, identified by index.
      - id: reserved
        size: 20
      - id: data
        size: len_data
        doc: Starts immediately after this 0x20-byte header.
      - id: pad
        size: (32 - (len_data % 32)) % 32
        doc: |
          Padding to the next 32-byte boundary. Since every entry header
          is itself 0x20 (32) bytes and the first one starts at the
          32-aligned offset 0x40, this keeps every entry header 32-byte
          aligned from the start of the file, matching BrawlLib's
          `round_up(dataOffset + size, 0x20)`.
    enums:
      file_type:
        1: misc_data
        2: model
        3: texture
        4: animation
        5: scene
        6: type6
        7: grouped_archive
        8: effect
