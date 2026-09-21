meta:
  id: nif
  endian: be
  title: Gamebryo NIF (Wii build 20.6.0.0)
doc: |
  Gamebryo scene/model file ("Gamebryo File Format, Version 20.6.0.0"),
  the Wii-era build used by Pocoyo Racing and parsed by NifOpen() in
  lib-nif.c. The text banner and the first few little-endian header
  fields are followed by an entirely big-endian body: a type-name
  table, one type index and size per block, a shared string table,
  group-size table, the block payloads themselves, and finally the
  scene root references. Block *contents* are polymorphic per
  NiObject type (see lib-nif.c's per-block readers for
  NiPersistentSrcTextureRendererData / NiMesh / NiDataStream etc.);
  only the fixed outer skeleton is modeled here.
seq:
  - id: header_str
    type: strz
    encoding: ASCII
    doc: '"Gamebryo File Format, Version 20.6.0.0\n"'
  - id: version
    type: u4le
    doc: 0x14060000.
  - id: is_big_endian
    type: u1
    doc: 0 = big-endian body (the only variant this codebase reads).
  - id: user_version
    type: u4le
  - id: n_blocks
    type: u4le
  - id: n_types
    type: u2
  - id: types
    type: type_entry
    repeat: expr
    repeat-expr: n_types
  - id: block_type_index
    type: u2
    repeat: expr
    repeat-expr: n_blocks
  - id: block_size
    type: u4
    repeat: expr
    repeat-expr: n_blocks
  - id: n_strings
    type: u4
  - id: max_string_length
    type: u4
  - id: strings
    type: type_entry
    repeat: expr
    repeat-expr: n_strings
  - id: n_groups
    type: u4
  - id: group_sizes
    type: u4
    repeat: expr
    repeat-expr: n_groups
  - id: blocks
    size: block_size[_index]
    repeat: expr
    repeat-expr: n_blocks
  - id: n_roots
    type: u4
  - id: root_refs
    type: u4
    repeat: expr
    repeat-expr: n_roots
types:
  type_entry:
    seq:
      - id: len
        type: u4
      - id: chars
        type: str
        size: len
        encoding: ASCII
        doc: |
          Generic types (e.g. array template args) separate their
          parts with \x01.
  strz:
    seq:
      - id: value
        type: str
        terminator: 0x0a
        encoding: ASCII
