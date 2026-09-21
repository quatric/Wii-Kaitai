meta:
  id: smashlvd
  endian: be
  title: Super Smash Bros. 4 stage/level data (LVD)
doc: |
  Super Smash Bros. 4 stage/level data (.lvd), per lib-smashlvd.c
  (ported from KillzXGaming/Smash-Forge LVD.cs). Only the fixed
  10-byte file header is modeled; the body is 19 counted lists in a
  fixed order, each a `0x01 tag + s32 count` prefix followed by
  tag-byte-prefixed variable-length records (collision lines,
  spawns, item/enemy generators, camera/blast zone boxes, etc.) --
  a tagged record stream, not a fixed layout, so it is left raw.

  nintoolbox's decoder validates all 19 list prefixes and requires lists 7–11
  to be empty. It rejects truncated fields and every missing `0x01` field tag;
  individual collision, spawn, and item records also begin with distinct
  12-byte identity constants before their tagged payloads.
seq:
  - id: unknown_magic
    contents: [0x00, 0x00, 0x00, 0x01]
    doc: Fixed big-endian leading value 1.
  - id: unknown_04
    contents: [0x0a]
    doc: Fixed header byte 0x0a.
  - id: unknown_05
    contents: [0x01]
    doc: Fixed header byte 0x01.
  - id: magic
    contents: "LVD1"
    doc: ASCII format signature.
  - id: body
    size-eos: true
    doc: Nineteen ordered counted, tagged-list streams.
