meta:
  id: gamedata_fat
  title: Battle of Giants gamedata.fat
  file-extension: fat
  endian: be
doc: |
  `gamedata.fat` (Battle of Giants: Dinosaurs Strike, Wii), the index of the
  `gamedata` archive next to it. Offsets ascend and the member sizes are the
  gaps between them (the last runs to the end of `gamedata`); every member is
  one zlib stream. A decoded resource starts `{u32 kind, u32 size,
  u32 type_hash, u32 id}` followed by the payload.
seq:
  - id: num_entries
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: id
        type: u4
        doc: The number the game's bink files are named after.
      - id: zero
        type: u4
      - id: offset
        type: u4
        doc: Into the `gamedata` file.
  resource:
    doc: Header of a decoded member.
    seq:
      - id: kind
        type: u4
      - id: len_payload
        type: u4
      - id: type_hash
        type: u4
      - id: id
        type: u4
