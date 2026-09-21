meta:
  id: numdlb
  file-extension:
    - numdlb
    - nusrcmdlb
  endian: le
  title: Bandai Namco SSBH model descriptor (Super Smash Bros. Ultimate)
doc: |
  SSBH MODL container (`.numdlb` / `.nusrcmdlb`), Super Smash Bros. Ultimate.
  Reference: ultimate-research/ssbh_lib `ssbh_lib/src/formats/modl.rs`
  (`Modl::V17`). Ties the mesh (.numshb), skeleton (.nusktb), materials
  (.numatb) and, optionally, animation (.nuanmb) file names together and
  assigns a material label to each mesh object. Ported from
  `lib-numdlb.c`/`.h`.
seq:
  - id: magic
    contents: [0x48, 0x42, 0x53, 0x53] # "HBSS"
  - id: unk1
    type: u8
    doc: Always 0x40 on retail files.
  - id: sub_magic
    contents: [0x4c, 0x44, 0x4f, 0x4d] # "LDOM" ("MODL" byte-reversed)
  - id: version_major
    type: u2
  - id: version_minor
    type: u2
  - id: model_name
    type: ssbh_string
  - id: skeleton_file_name
    type: ssbh_string
  - id: material_file_names
    type: ssbh_array
    doc: SsbhArray<SsbhString>.
  - id: animation_file_name
    type: u8
    doc: |
      RelPtr64<SsbhString> -- a pointer to a second SsbhString field
      elsewhere in the file, so reading it takes two hops: this field's own
      relative offset lands on an SsbhString field, whose own relative
      offset (relative to itself) leads to the actual string bytes. Null
      (0) if there's no associated .nuanmb.
  - id: mesh_file_name
    type: ssbh_string
    doc: SsbhString8, read identically to SsbhString.
  - id: entries
    type: ssbh_array
    doc: SsbhArray<ModlEntry>, element size 0x18.
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
  modl_entry:
    doc: 0x18 bytes, relative to the entries array's own element base.
    seq:
      - id: mesh_object_name
        type: ssbh_string
      - id: mesh_object_subindex
        type: u8
      - id: material_label
        type: ssbh_string
