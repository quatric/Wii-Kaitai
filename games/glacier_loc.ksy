meta:
  id: glacier_loc
  title: IO Interactive Glacier localisation tree (.LOC)
  file-extension: loc
  endian: le
doc: |
  Group: {u8 count, (count - 1) x u32 offset of child i relative to child 0},
  child 0 follows. Child = {NUL-terminated name, u8 type}: 0x10 group (count +
  offsets), 0x09 string (UTF-8, NUL, u32 0), 0x29 string with extra {NUL,
  u32 id, u32 id}, 0x08 name only. The walk must end exactly at EOF.
seq:
  - id: root
    type: group
types:
  group:
    seq:
      - id: count
        type: u1
      - id: child_offsets
        type: u4
        repeat: expr
        repeat-expr: count - 1
        if: count > 0
      - id: children
        type: child
        repeat: expr
        repeat-expr: count
  child:
    seq:
      - id: name
        type: strz
        encoding: UTF-8
      - id: type
        type: u1
      - id: body
        type:
          switch-on: type
          cases:
            0x10: group
            0x09: string_body
            0x29: string_id_body
  string_body:
    seq:
      - id: text
        type: strz
        encoding: UTF-8
      - id: zero
        type: u4
  string_id_body:
    seq:
      - id: text
        type: strz
        encoding: UTF-8
      - id: id_a
        type: u4
      - id: id_b
        type: u4
