meta:
  id: tvol
  endian: le
  title: Koei Tecmo / Gust Texture Volume Archive (.tvol)
doc: |
  Koei Tecmo / Gust Texture Volume Archive, per lib-tvol.c. Each
  member's name is a NUL-terminated string stored inline at the
  start of its own data.
seq:
  - id: num_textures
    type: u4
  - id: entries
    type: entry_t
    repeat: expr
    repeat-expr: num_textures
types:
  entry_t:
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
    instances:
      name:
        pos: offset
        type: str
        size: 48
        encoding: ASCII
        terminator: 0
        io: _root._io
        if: size != 0
      body:
        pos: offset
        size: size
        io: _root._io
