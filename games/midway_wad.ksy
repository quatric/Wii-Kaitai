meta:
  id: midway_wad
  title: Midway WAD resource pack (.WAD)
  file-extension: wad
  endian: be
doc: |
  Midway/Shell-style `.WAD` resource pack (TNA Impact!, Wii). A chain of
  records, each a 0x20-byte header and `size` payload bytes; the chain ends at
  a `WEND` record. Known types include TIM, SPR, PHM, FNT, PHA, TXT, GAM,
  SFX and TOC.
seq:
  - id: records
    type: record
    repeat: until
    repeat-until: _.type == 'WEND' or _io.eof
types:
  record:
    seq:
      - id: name
        size: 16
        type: strz
        encoding: ASCII
      - id: type
        type: str
        size: 4
        encoding: ASCII
      - id: size
        type: u4
      - id: reserved
        size: 12
      - id: payload
        size: size
