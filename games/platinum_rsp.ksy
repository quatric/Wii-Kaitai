meta:
  id: platinum_rsp
  title: PlatinumGames PACK sound pack (.rsp)
  file-extension: rsp
  endian: be
doc: |
  PlatinumGames `PACK` sound pack (MadWorld, Wii). Offsets are from the start of
  the pack, which may itself be a member of an outer pack. A member starting with
  `PACK` is a nested pack, every other member is a RedSpark `.rsd` sound.
seq:
  - id: magic
    contents: PACK
  - id: count
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: offset
        type: u4
      - id: len_data
        type: u4
