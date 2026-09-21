meta:
  id: bcres
  file-extension: bcres
  endian: le
  title: NintendoWare NW4C CGFX container (BCRES/BCMDL)
doc: |
  The 3DS "CGFX" container (`.bcres`/`.bcmdl`/`.ctex...`, all the same
  `CGFX` magic) holding models, textures, materials, shaders and
  animations. Every offset in a CGFX is self-relative: a stored value is
  added to the address of the *field that stores it*, not to any shared
  base.

  Right after the fixed header comes a `DATA` block: 16 fixed (count,
  self-relative pointer) pairs, one per resource kind (models, textures,
  LUTs, materials, shaders, cameras, lights, fogs, scenes, and six
  animation kinds, plus emitters -- see `dict_kind`). Each non-empty
  pair points to a `DICT`, a binary (Patricia) trie whose nodes resolve
  to a NUL-terminated name and a self-relative pointer to that
  resource's own record.

  This definition follows the container down to each named resource's
  address and stops there: decoding a model's skeleton/geometry, a
  material's PICA200 command list, or a texture's pixel format is
  version-specific, deeply nested work this project's own reader does
  procedurally (`lib-bcres.c`, ~2800 lines) rather than through one fixed
  struct, matching the scope line `bch.ksy` draws for the same PICA200
  hardware on the SMDH/BCH side.
seq:
  - id: magic
    contents: "CGFX"
  - id: bom
    type: u2
  - id: len_header
    type: u2
  - id: revision
    type: u4
instances:
  data_block:
    io: _root._io
    pos: len_header
    type: data_block
types:
  data_block:
    seq:
      - id: magic
        contents: "DATA"
      - id: len_block
        type: u4
      - id: dicts
        type: dict_ref
        repeat: expr
        repeat-expr: 16
    types:
      dict_ref:
        seq:
          - id: count
            type: u4
          - id: ofs_dict
            type: s4
            doc: Self-relative to this field's own address (i.e. this field's file offset + this value).
        instances:
          dict:
            io: _root._io
            pos: _io.pos - 4 + ofs_dict
            type: dict
            if: count > 0 and count <= 0x10000
  dict:
    seq:
      - id: magic
        contents: "DICT"
      - id: len_block
        type: u4
      - id: num_nodes
        type: u4
        doc: Excludes the tree's own root node (node 0).
      - id: nodes
        type: node
        repeat: expr
        repeat-expr: num_nodes + 1
    types:
      node:
        seq:
          - id: ref_bit
            type: u4
          - id: idx_left
            type: u2
          - id: idx_right
            type: u2
          - id: ofs_name
            type: s4
            doc: Self-relative to this field's own address; node 0 (the root) has no valid name/data.
          - id: ofs_data
            type: s4
            doc: Self-relative to this field's own address; the referenced resource's own record is not modeled here.
        instances:
          node_start:
            value: _io.pos - 16
            doc: This node's own starting file offset (the whole fixed-size record is 16 bytes).
          name:
            io: _root._io
            pos: node_start + 8 + ofs_name
            type: strz
            encoding: ASCII
          abs_data_offset:
            value: node_start + 12 + ofs_data
enums:
  dict_kind:
    0: models
    1: textures
    2: luts
    3: materials
    4: shaders
    5: cameras
    6: lights
    7: fogs
    8: scenes
    9: skeletal_anim
    10: material_anim
    11: visibility_anim
    12: camera_anim
    13: light_anim
    14: fog_anim
    15: emitters
