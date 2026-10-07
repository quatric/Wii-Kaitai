meta:
  id: natsume_bin
  title: Natsume "BIN" archive (Harvest Moon Wii)
  file-extension: bin
  endian: le
doc: |
  Natsume's `BIN\0` archive from the Wii Harvest Moon games (Magical Melody,
  Tree of Tranquility, ...). Layout worked out from the 134 `FSH_*` /
  character-animation archives of Magical Melody; every one satisfies it.
  Members are stored plain. A member starting with a short printable tag
  (`cdt`, `mss`) is given that as its extension, otherwise `.bin`.
seq:
  - id: magic
    contents: ['BIN', 0]
  - id: version
    type: u2
    doc: Always 1.
  - id: flags
    type: u2
    doc: Always 1.
  - id: count
    type: u4
  - id: reserved
    type: u4
    doc: Always 0.
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: reserved
        size: 8
        doc: Two zero words.
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
