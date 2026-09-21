meta:
  id: numatb
  file-extension: numatb
  endian: le
  title: Bandai Namco SSBH material container (Super Smash Bros. Ultimate)
doc: |
  SSBH MATL container (`.numatb`), Super Smash Bros. Ultimate. Reference:
  ultimate-research/ssbh_lib `ssbh_lib/src/{lib.rs,arrays.rs,strings.rs,
  enums.rs,formats/matl.rs}`. Ported from `lib-numatb.c`/`.h`.

  BlendState/RasterizerState differ in size between file version 1.5 and
  1.6 (matl.rs's BlendStateV15/V16, RasterizerStateV15/V16); this
  definition only models the attribute table itself (param id + tagged
  value), not those two variable-size state blobs, matching the reference
  decoder's own scope.
seq:
  - id: magic
    contents: [0x48, 0x42, 0x53, 0x53] # "HBSS"
  - id: unk1
    type: u8
    doc: Always 0x40 on retail files.
  - id: sub_magic
    contents: [0x4c, 0x54, 0x41, 0x4d] # "LTAM" ("MATL" byte-reversed)
  - id: version_major
    type: u2
  - id: version_minor
    type: u2
  - id: entries
    type: ssbh_array
    doc: SsbhArray<MatlEntry>, element size 0x20.
types:
  ssbh_array:
    seq:
      - id: ofs_rel
        type: u8
      - id: count
        type: u8
  ssbh_string:
    seq:
      - id: ofs_rel
        type: u8
  matl_entry:
    doc: |
      0x20 bytes, relative to the entries array's own element base (same
      layout for file version 1.5 and 1.6).
    seq:
      - id: material_label
        type: ssbh_string
      - id: attributes
        type: ssbh_array
        doc: SsbhArray<Attribute>, element size 0x18.
      - id: shader_label
        type: ssbh_string
  attribute:
    doc: 0x18 bytes, relative to the attributes array's own element base.
    seq:
      - id: param_id
        type: u8
        doc: See matl_param_names in lib-numatb.c (ParamId enum in matl.rs).
      - id: param
        type: ssbh_enum64
        doc: |
          u64 relative offset (relative to THIS field's own position,
          i.e. entry_off+0x08) to the value, then u64 data_type
          discriminant:
            1  Float           f32                          (4 bytes)
            2  Boolean         u32 (0/1)                     (4 bytes)
            5  Vector4         4x f32 (x,y,z,w)              (16 bytes)
            7  Color4f (Unk7)  4x f32 (r,g,b,a)              (16 bytes)
            11 String          SsbhString                    (8 bytes)
            14 Sampler         6x u32 wrap/min/mag/filter,
                                Color4f border, 2x u32 unk,
                                f32 lod_bias, u32 max_aniso   (0x38 bytes)
            16 UvTransform     5x f32                         (20 bytes)
            17 BlendState      version-dependent (not modelled here)
            18 RasterizerState version-dependent (not modelled here)
  ssbh_enum64:
    seq:
      - id: ofs_rel
        type: u8
      - id: data_type
        type: u8
  sampler_value:
    doc: 0x38 bytes.
    seq:
      - id: wraps
        type: u4
      - id: wrapt
        type: u4
      - id: wrapr
        type: u4
      - id: min_filter
        type: u4
      - id: mag_filter
        type: u4
      - id: filter_type
        type: u4
      - id: border_color
        size: 16
        doc: Color4f (r,g,b,a as f32).
      - id: unk1
        type: u4
      - id: unk2
        type: u4
      - id: lod_bias
        type: f4
      - id: max_anisotropy
        type: u4
  uv_transform_value:
    doc: 20 bytes.
    seq:
      - id: scale_u
        type: f4
      - id: scale_v
        type: f4
      - id: rotation
        type: f4
      - id: translate_u
        type: f4
      - id: translate_v
        type: f4
