meta:
  id: mtmob
  endian: le
  title: Capcom MT Framework Mobile model/texture/material/shader (3DS)
doc: |
  Capcom MT Framework Mobile (Nintendo 3DS: Resident Evil Revelations /
  Mercenaries 3D, Monster Hunter 3U/4 era) file family, as probed by
  IsMTMOD()/IsMTTEX()/IsMTMRL()/IsMTMFX() in lib-mtmob.c (ported from
  SPICA by gdkchan). All four share a 4-byte NUL-padded magic
  ("MOD\0" / "TEX\0" / "MRL\0" / "MFX\0") but otherwise have unrelated
  layouts; only the two with a simple, fully bounds-checked header
  (MOD and TEX) are modeled precisely here. MRL/MFX are variable
  dictionary-style tables (see mt_parse_mrl()/mt_parse_layouts() in
  lib-mtmob.c) and are left as an opaque body.
seq:
  - id: magic
    size: 4
  - id: body
    size-eos: true
    type:
      switch-on: magic
      cases:
        '[0x4d, 0x4f, 0x44, 0x00]': mod_body
        '[0x54, 0x45, 0x58, 0x00]': tex_body
types:
  mod_body:
    doc: 'MT MOD ("MOD\0") model: skeleton, meshes and material name table.'
    seq:
      - id: unknown1
        size: 2
      - id: n_bones
        type: u2
      - id: n_meshes
        type: u2
      - id: n_materials
        type: u2
      - id: unknown2
        size: 0x18 - 0xc
      - id: vertex_buffer_len
        type: u4
      - id: unknown3
        size: 0x24 - 0x1c
      - id: n_bone_groups
        type: u4
      - id: skeleton_off
        type: u4
      - id: unknown4
        size: 4
      - id: material_names_off
        type: u4
      - id: mesh_table_off
        type: u4
      - id: vertex_buffer_off
        type: u4
      - id: index_buffer_off
        type: u4
      - id: file_length
        type: u4
        doc: Retail files record their own total size here (flen).
    instances:
      meshes:
        type: mesh_entry
        repeat: expr
        repeat-expr: n_meshes
        pos: mesh_table_off
        io: _root._io
      material_names:
        type: material_name
        repeat: expr
        repeat-expr: n_materials
        pos: material_names_off
        io: _root._io
  mesh_entry:
    doc: One 0x28-byte MOD mesh descriptor (see ParseMTMOD() in lib-mtmob.c).
    seq:
      - id: unknown1
        size: 2
      - id: vertex_count
        type: u2
      - id: mat_mesh
        type: u4
        doc: Packed render-type (byte 3) + material index (bits 12-23).
      - id: unknown2
        size: 2
      - id: stride
        type: u1
      - id: unknown3
        size: 1
      - id: vertex_index
        type: u4
      - id: vertex_offset
        type: u4
      - id: format_hash
        type: u4
        doc: CRC32 key matched against an MFX sibling's input-layout table.
      - id: index_index
        type: u4
      - id: index_count
        type: u4
      - id: unknown4
        size: 0x24 - 0x1c - 4
      - id: bone_count
        type: u1
      - id: bone_group_index
        type: u1
      - id: unknown5
        size: 2
  material_name:
    seq:
      - id: name
        type: str
        size: 0x80
        encoding: ASCII
        terminator: 0
  tex_body:
    doc: |
      MT TEX ("TEX\0") texture: three packed geometry/format words,
      then PICA200-ordered texel data (see DecodeMTTEX_RGBA()).
    seq:
      - id: word0
        type: u4
      - id: word1
        type: u4
      - id: word2
        type: u4
    instances:
      version:
        value: word0 & 0xfff
      shift:
        value: (word0 >> 24) & 0xf
      width:
        value: ((word1 >> 6) & 0x1fff) << shift
      height:
        value: ((word1 >> 19) & 0x1fff) << shift
      format:
        value: (word2 >> 8) & 0xff
