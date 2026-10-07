meta:
  id: startrek_wii_tex
  title: Star Trek Conquest "WII!" texture bundle
  file-extension: wii
  endian: be
doc: |
  "WII!" texture bundle of Star Trek: Conquest (`.wii` / `.WII`). A 0x40-byte
  header, then `count` 0x18-byte records at 0x40. Two record layouts share the
  magic; nintoolbox tells them apart by the word at 0x0c (`0` = texture-only,
  non-zero = mixed level bundle).

  Texture-only bundles (63 files such as `Splash/*.WII`): records
  `{char name[4], u2 w, u2 h, u4 kind, u4 0, u4 size, u4 offset}` where
  kind 0 = RGBA8 (`size = w*h*4`), 1 = RGB565 (`w*h*2`), 2 = a 16-bit alpha
  format decoded as RGB5A3 (best guess).

  Mixed level bundles (82 files): records
  `{u4 0, u2 w, u2 h, u2 type, u2 wide, u4 0, u4 size, u4 offset}` where `size`
  covers a full mip chain. nintoolbox decodes types 4..7 at the base level:
  `wide = 0` -> RGBA8, `wide = 1` -> RGB565 (type 6) or RGB5A3 (other types,
  best guess).
seq:
  - id: magic
    contents: 'WII!'
  - id: version
    type: u4
    doc: 2.
  - id: count
    type: u4
  - id: mixed_flag
    type: u4
    doc: Offset 0x0c. Zero for texture-only bundles.
  - id: unknown_10
    size: 0x40 - 0x10
  - id: texture_records
    type: texture_record
    repeat: expr
    repeat-expr: count
    if: not is_mixed
  - id: mixed_records
    type: mixed_record
    repeat: expr
    repeat-expr: count
    if: is_mixed
instances:
  is_mixed:
    value: mixed_flag != 0
types:
  texture_record:
    seq:
      - id: name
        type: str
        size: 4
        encoding: ASCII
      - id: width
        type: u2
      - id: height
        type: u2
      - id: kind
        type: u4
        enum: kind
      - id: zero
        type: u4
      - id: size
        type: u4
      - id: offset
        type: u4
    instances:
      data:
        pos: offset
        size: size
        io: _root._io
  mixed_record:
    seq:
      - id: zero_00
        type: u4
      - id: width
        type: u2
      - id: height
        type: u2
      - id: type
        type: u2
      - id: wide
        type: u2
        doc: 0 or 1.
      - id: zero_0c
        type: u4
      - id: size
        type: u4
      - id: offset
        type: u4
    instances:
      data:
        pos: offset
        size: size
        io: _root._io
enums:
  kind:
    0: rgba8
    1: rgb565
    2: rgb5a3_guess
