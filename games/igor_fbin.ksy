meta:
  id: igor_fbin
  title: Igor The Game bitmap font metrics (.fbin / .sfbin)
  endian: le
doc: |
  A stream of u32 values at any byte offset. Signature "FRITE" as five u32
  characters, {u32 18, u32 1, u32 name length, name bytes}, {u32 sprite count N,
  u32 0}, N sprite rectangles {s32 x, y, width, height, flags} (.sfbin: {index,
  0}), then character blocks until EOF: {u32 first code point, u32 count} then
  count characters {u32 advance, u32 sprite count, per sprite {u32 sprite index,
  s32 x offset, s32 y offset}}.
seq:
  - id: signature
    type: u4
    repeat: expr
    repeat-expr: 5
    doc: F R I T E as u32 characters.
  - id: eighteen
    type: u4
  - id: one
    type: u4
  - id: name_length
    type: u4
  - id: name
    size: name_length
    type: strz
    encoding: ASCII
  - id: sprite_count
    type: u4
  - id: zero
    type: u4
  - id: sprites
    type: sprite
    repeat: expr
    repeat-expr: sprite_count
  - id: blocks
    type: char_block
    repeat: eos
types:
  sprite:
    seq:
      - id: x
        type: s4
      - id: y
        type: s4
      - id: width
        type: s4
      - id: height
        type: s4
      - id: flags
        type: s4
  char_block:
    seq:
      - id: first_code_point
        type: u4
      - id: count
        type: u4
      - id: chars
        type: char
        repeat: expr
        repeat-expr: count
  char:
    seq:
      - id: advance
        type: u4
      - id: sprite_count
        type: u4
      - id: sprites
        type: char_sprite
        repeat: expr
        repeat-expr: sprite_count
  char_sprite:
    seq:
      - id: sprite_index
        type: u4
      - id: x_offset
        type: s4
      - id: y_offset
        type: s4
