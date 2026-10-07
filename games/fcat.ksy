meta:
  id: fcat
  title: FCAT container (Winning Post .dat)
  file-extension: dat
  endian: be
doc: |
  "FCAT" container from Winning Post 7 / World (Wii). A count and an array of
  `(offset, size)` pairs; members are stored raw (mostly `bres` BRRES files)
  and are named by index plus an extension derived from their magic.
seq:
  - id: magic
    contents: 'FCAT'
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
      - id: size
        type: u4
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
