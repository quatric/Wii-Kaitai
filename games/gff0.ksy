meta:
  id: gff0
  title: GFF0 effect database (gffData.bin)
  file-extension: bin
  endian: be
doc: |
  `GFF0` effect database (Trauma Center: New Blood / Trauma Team, Wii
  `effect/gffData.bin`). Each effect block starts with a 0x50-byte header, then
  `num_parts` part records, each starting 0x30 bytes before its 16-byte name
  (`PartsNNN`). Type 1 parts are 0x50 + 0x90 bytes plus a tail of 0x10-byte
  groups, other types 0x40..0x50 bytes; part sizes are taken from the name
  positions because the size field was not identified, so the part records are
  left as raw bytes.
seq:
  - id: magic
    contents: GFF0
  - id: zero
    type: u4
  - id: len_file
    type: u4
  - id: header_size_a
    type: u4
    doc: 0x20.
  - id: header_size_b
    type: u4
    doc: 0x20.
  - id: num_effects
    type: u4
  - id: reserved
    size: 8
  - id: effects
    type: effect
    repeat: expr
    repeat-expr: num_effects
types:
  effect:
    seq:
      - id: reserved0
        size: 8
      - id: duration
        type: f4
      - id: reserved1
        size: 8
      - id: len_block
        type: u4
        doc: Headers + parts.
      - id: reserved2
        size: 8
      - id: num_parts
        type: u4
      - id: reserved3
        size: 12
      - id: name
        size: 16
        type: strz
        encoding: ASCII
        doc: '"Effect001", "Eff056", ...'
      - id: reserved4
        size: 0x10
      - id: parts_raw
        size: len_block - 0x50
