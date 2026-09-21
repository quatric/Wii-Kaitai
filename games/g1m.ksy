meta:
  id: g1m
  file-extension: g1m
  endian: le
  title: Koei Tecmo G1M model container
doc: |
  Little-endian chunked 3D model container used by Koei Tecmo titles
  (Hyrule Warriors, Fire Emblem Warriors). Ported from nintoolbox's
  `lib-g1m.c`; verified against 40 retail models from Hyrule Warriors
  Legends (3DS).

  The magic reads `_M1G` on disk but decodes as `G1M_` when read as a
  big-endian tag, matching the convention used by chunk tags inside the
  file (e.g. the geometry chunk is stored `GM1G`, i.e. `G1MG` byte
  reversed).
seq:
  - id: magic
    contents: "_M1G"
  - id: version
    size: 4
  - id: file_size
    type: u4
  - id: header_size
    type: u4
  - id: reserved
    type: u4
  - id: num_chunks
    type: u4
  - id: chunks
    type: chunk
    repeat: expr
    repeat-expr: num_chunks
types:
  chunk:
    seq:
      - id: magic
        size: 4
        doc: Byte-reversed 4-character tag, e.g. "GM1G" for the G1MG geometry chunk.
      - id: version
        size: 4
      - id: size
        type: u4
      - id: body
        size: size
