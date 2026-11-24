meta:
  id: nifclassic
  title: Gamebryo 2.x NIF scene header (20.3.0.9, big endian)
  file-extension: nif
doc: |
  "Gamebryo File Format, Version 20.3.0.9\n", u32 LE version, u8 endian (0 =
  big), u32 user version, u32 LE block count, then big endian: u16 type count,
  types {u32 length, name}, u16 block type per block, u32 size per block, u32
  string count, u32 max length, strings {u32 length, text}, u32 group count +
  groups, block data back to back, u32 root count + roots.
seq:
  - id: banner
    type: strz
    terminator: 0x0a
    encoding: ASCII
    consume: true
  - id: version
    type: u4le
  - id: endian
    type: u1
  - id: user_version
    type: u4le
  - id: block_count
    type: u4le
  - id: type_count
    type: u2be
  - id: types
    type: type_name
    repeat: expr
    repeat-expr: type_count
  - id: block_types
    type: u2be
    repeat: expr
    repeat-expr: block_count
  - id: block_sizes
    type: u4be
    repeat: expr
    repeat-expr: block_count
  - id: string_count
    type: u4be
  - id: max_string_length
    type: u4be
  - id: strings
    type: gb_string
    repeat: expr
    repeat-expr: string_count
  - id: group_count
    type: u4be
  - id: groups
    type: u4be
    repeat: expr
    repeat-expr: group_count
  - id: blocks
    size-eos: true
types:
  type_name:
    seq:
      - id: length
        type: u4be
      - id: name
        size: length
        type: str
        encoding: ASCII
  gb_string:
    seq:
      - id: length
        type: u4be
      - id: text
        size: length
        type: str
        encoding: ASCII
