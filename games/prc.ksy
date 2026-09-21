meta:
  id: prc
  title: Smash Ultimate parameter binary (PRC / "paracobn")
  file-extension:
    - prc
    - param
  endian: le
  license: CC0-1.0

doc: |
  Super Smash Bros. Ultimate parameter binary, magic "paracobn". A Hash40
  label table, a reference section (strings + struct key tables), and a
  parameter tree whose root value is always a struct (type 12).

  Reference: nintoolbox project/src/lib-prc.c (DecodePRC_XML), itself a
  reimplementation of ultimate-research/prc-rs's disasm.rs.

  Older Smash 4 era variants ("parambinary", "PRC\0", "BPAR") are a
  different, undocumented layout and are not modeled here.

seq:
  - id: magic
    contents: "paracobn"
  - id: hash_table_size
    type: u4
    doc: Always a multiple of 8.
  - id: reference_section_size
    type: u4
  - id: hashes
    type: u8
    repeat: expr
    repeat-expr: hash_table_size / 8

instances:
  reference_section_start:
    value: 16 + hash_table_size
  param_start:
    value: reference_section_start + reference_section_size
  root_value:
    pos: param_start
    type: value

types:
  value:
    seq:
      - id: value_type
        type: u1
        enum: value_type
      - id: body
        type:
          switch-on: value_type
          cases:
            'value_type::bool_': u1
            'value_type::i8': s1
            'value_type::u8': u1
            'value_type::i16': s2
            'value_type::u16': u2
            'value_type::i32': s4
            'value_type::u32': u4
            'value_type::f32': f4
            'value_type::hash': hash_ref
            'value_type::string': string_ref
            'value_type::list': list_value
            'value_type::struct_': struct_value
    enums:
      value_type:
        1: bool_
        2: i8
        3: u8
        4: i16
        5: u16
        6: i32
        7: u32
        8: f32
        9: hash
        10: string
        11: list
        12: struct_

  hash_ref:
    doc: u32 index into the outer file's Hash40 label table.
    seq:
      - id: label_index
        type: u4

  string_ref:
    doc: u32 offset relative to the reference section, NUL-terminated.
    seq:
      - id: ref_offset
        type: u4

  list_value:
    seq:
      - id: count
        type: u4
      - id: item_offsets
        type: u4
        repeat: expr
        repeat-expr: count
        doc: Each offset is relative to this value's own type byte.

  struct_value:
    seq:
      - id: count
        type: u4
      - id: key_table_offset
        type: u4
        doc: Relative to the start of the reference section.
    instances:
      keys:
        pos: _root.reference_section_start + key_table_offset
        type: struct_key
        repeat: expr
        repeat-expr: count

  struct_key:
    doc: |
      count (u32 label index into the outer hash table, u32 value offset
      relative to this struct value's own type byte) pairs. The reference
      decoder sorts these by label index before use.
    seq:
      - id: label_index
        type: u4
      - id: value_offset
        type: u4
