meta:
  id: nuhlpb
  file-extension: nuhlpb
  endian: le
  title: Bandai Namco SSBH helper-bone constraints (Super Smash Bros. Ultimate)
doc: |
  SSBH HLPB container (`.nuhlpb`), Super Smash Bros. Ultimate. Reference:
  ultimate-research/ssbh_lib `ssbh_lib/src/formats/hlpb.rs` (`Hlpb::V11`).
  Ported from `lib-nuhlpb.c`/`.h`.
seq:
  - id: magic
    contents: [0x48, 0x42, 0x53, 0x53] # "HBSS"
  - id: unk1
    type: u8
    doc: Always 0x40 on retail files.
  - id: sub_magic
    contents: [0x42, 0x50, 0x4c, 0x48] # "BPLH" ("HLPB" byte-reversed)
  - id: version_major
    type: u2
  - id: version_minor
    type: u2
  - id: aim_constraints
    type: ssbh_array
    doc: SsbhArray<AimConstraint>, element size 0x90.
  - id: orient_constraints
    type: ssbh_array
    doc: SsbhArray<OrientConstraint>, element size 0x70.
  - id: constraint_indices
    type: ssbh_array
    doc: |
      SsbhArray<u32>. Per constraint (ordered by application), the index
      into whichever of the two arrays above constraint_types (below) says
      it belongs to.
  - id: constraint_types
    type: ssbh_array
    doc: SsbhArray<u32>. 0 = Aim, 1 = Orient.
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
  vector3:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
  vector4:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
      - id: w
        type: f4
  aim_constraint:
    doc: 0x90 bytes, relative to the aim_constraints array's own element base.
    seq:
      - id: name
        type: ssbh_string
      - id: aim_bone_name1
        type: ssbh_string
      - id: aim_bone_name2
        type: ssbh_string
      - id: aim_type1
        type: ssbh_string
        doc: Always "DEFAULT".
      - id: aim_type2
        type: ssbh_string
        doc: Always "DEFAULT".
      - id: target_bone_name1
        type: ssbh_string
      - id: target_bone_name2
        type: ssbh_string
      - id: unk1
        type: u4
        doc: Always 0.
      - id: unk2
        type: u4
        doc: Always 1.
      - id: aim
        type: vector3
        doc: Local axis to constrain, usually X+ (1,0,0).
      - id: up
        type: vector3
      - id: quat1
        type: vector4
      - id: quat2
        type: vector4
      - id: unk17_22
        size: 24
        doc: 6x f32, always 0.
  orient_constraint:
    doc: 0x70 bytes, relative to the orient_constraints array's own element base.
    seq:
      - id: name
        type: ssbh_string
      - id: parent_bone_name1
        type: ssbh_string
      - id: parent_bone_name2
        type: ssbh_string
      - id: source_bone_name
        type: ssbh_string
      - id: target_bone_name
        type: ssbh_string
      - id: unk_type
        type: u4
        doc: 0, 1 or 2 -- usually 1 or 2.
      - id: constraint_axes
        type: vector3
        doc: Per-axis source/target interpolation factor.
      - id: quat1
        type: vector4
      - id: quat2
        type: vector4
      - id: range_min
        type: vector3
        doc: Always -180,-180,-180.
      - id: range_max
        type: vector3
        doc: Always 180,180,180.
