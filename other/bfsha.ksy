meta:
  id: bfsha
  file-extension: bfsha
  endian: le
  title: Nintendo Switch Binary Shader Archive (BFSHA)
doc: |
  A Switch shader archive: a BFRES-family `BinaryHeader` (shared with
  BNSH/BNTX) followed by a name/path string pair and a `ResDict`-indexed
  array of shader models. Reference: KillzXGaming/BfshaLibrary
  (ShaderLibrary/Structs.cs, IO/BinaryDataReader.cs, Dict/ResDict.cs).

  This .ksy stops at locating each named shader model's own record --
  a model's own body is a *fixed-size* record whose exact size and
  field layout depends on `version_major` (0xc0 bytes below major 7,
  0xe8 at major 7, 0x100 from major 8 up: option/attribute/sampler/
  image/uniform-block ResDicts, a version-shaped `ShaderProgramHeader`
  array, and a per-program static+dynamic option-key table), which is
  real further per-version work this project's own reader does
  procedurally rather than through one fixed struct, so it is left
  unmodeled here.
seq:
  - id: magic
    contents: "FSHA"
  - id: magic_pad
    size: 4
  - id: version_micro
    type: u1
  - id: version_minor
    type: u1
  - id: version_major
    type: u2
  - id: bom
    type: u2
  - id: alignment
    type: u1
  - id: target_addr_size
    type: u1
  - id: ofs_name
    type: u4
  - id: flag
    type: u2
  - id: ofs_first_block
    type: u2
  - id: ofs_relocation_table
    type: u4
  - id: len_file
    type: u4
  - id: unknown0
    type: u8
  - id: ofs_string_pool
    type: u8
  - id: ofs_shader_model
    type: u8
    doc: Unused by this tool's reader.
  - id: ptr_name
    type: u8
    doc: BFRES-style string pointer (u16 length immediately precedes the NUL-terminated text).
  - id: ptr_path
    type: u8
  - id: ofs_models_array
    type: u8
  - id: ofs_models_dict
    type: u8
  - id: unknown1
    type: u4
    repeat: expr
    repeat-expr: 4
  - id: unknown2
    type: u8
  - id: v7_padding
    type: u8
    if: version_major >= 7
  - id: num_models
    type: u2
  - id: flag2
    type: u2
  - id: unused
    type: u2
instances:
  models_dict:
    io: _root._io
    pos: ofs_models_dict
    type: res_dict
    if: ofs_models_dict > 0
types:
  res_dict:
    doc: The generic BFRES-family "ResDict" binary-trie node table used for every named lookup in this format.
    seq:
      - id: magic
        type: u4
      - id: num_nodes
        type: s4
        doc: Excludes the tree's own root node.
      - id: nodes
        type: res_dict_node
        repeat: expr
        repeat-expr: num_nodes + 1
  res_dict_node:
    seq:
      - id: reference
        type: u4
      - id: idx_left
        type: u2
      - id: idx_right
        type: u2
      - id: ptr_key
        type: u8
