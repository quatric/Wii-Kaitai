meta:
  id: neko_grp
  title: Neko Entertainment MUSIC.GRP
  file-extension: grp
  endian: le
doc: |
  Neko Entertainment `MUSIC.GRP` (Cocoto Kart Racer 2 / Magic Circus, Wii).
  `count` pairs of `{size, offset}`. The first count/2 entries are 0x20-byte
  descriptors (big-endian words `{1, 2, 48000, ...}`); the last count/2 are
  raw big-endian 16-bit mono PCM tracks.
seq:
  - id: count
    type: u2
  - id: header_size
    type: u2
    doc: 0x20.
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: len_data
        type: u4
      - id: offset
        type: u4
    instances:
      data:
        pos: offset
        io: _root._io
        size: len_data
