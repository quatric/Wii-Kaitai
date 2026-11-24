meta:
  id: rspa
  title: Dragon Quest Monster Battle Road Victory pack (.RSPA)
  file-extension: rspa
  endian: le
doc: |
  Dragon Quest Monster Battle Road Victory (Wii) `RSPA/*.RSPA`. The member length
  is the distance to the next offset; the last member ends at the file end.
  Members are BRRES models/textures (`bres`), `RSM`/`RST`/`RSA` effect resources
  and `rss` sets.
seq:
  - id: magic
    contents: RSPA
  - id: count
    type: u4
  - id: size
    type: u4
    doc: About the file size, may be a few bytes more.
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: tag
        size: 4
      - id: offset
        type: u4
