meta:
  id: nufxlb
  file-extension: nufxlb
  endian: le
  title: Bandai Namco SSBH shader-effects library (Super Smash Bros. Ultimate)
doc: |
  SSBH NUFX container (`.nufxlb`), Super Smash Bros. Ultimate. Reference:
  ultimate-research/ssbh_lib `ssbh_lib/src/formats/nufx.rs` (`Nufx::V0`/`V1`,
  `ShaderProgramV0`/`V1`, `ShaderStages`, `VertexAttribute`,
  `MaterialParameter`). Ported from `lib-nufxlb.c`/`.h`.

  Same container conventions as this family's other SSBH decoders (NUMATB,
  NUMDLB, NUMSHB, NUANMB, NUHLPB, NULSTB): every pointer is a 64-bit offset
  relative to the field that holds it (`SsbhString`/`SsbhArray`).
seq:
  - id: magic
    contents: [0x48, 0x42, 0x53, 0x53] # "HBSS" (or "SSBH" on some tools)
  - id: unk1
    type: u8
    doc: Always 0x40 on retail files.
  - id: sub_magic
    contents: [0x58, 0x46, 0x55, 0x4e] # "XFUN" ("NUFX" byte-reversed)
  - id: version_major
    type: u2
  - id: version_minor
    type: u2
  - id: programs
    type: ssbh_array
    doc: SsbhArray<ShaderProgramV0|V1>, element size 0x50 (v1.0) or 0x60 (v1.1).
  - id: unk_string_list
    type: ssbh_array
    doc: Not decoded further by the reference decoder.
types:
  ssbh_array:
    doc: u64 relative offset (relative to this field's own position) + u64 count.
    seq:
      - id: ofs_rel
        type: u8
      - id: count
        type: u8
  ssbh_string:
    doc: u64 relative offset (relative to this field's own position) to a NUL-terminated string.
    seq:
      - id: ofs_rel
        type: u8
  shader_stages:
    doc: Six SsbhStrings naming shader stage entries resolved in a sibling .nushdb.
    seq:
      - id: vertex_shader
        type: ssbh_string
      - id: unk_shader1
        type: ssbh_string
        doc: Possibly tessellation-control.
      - id: unk_shader2
        type: ssbh_string
        doc: Possibly tessellation-evaluation.
      - id: geometry_shader
        type: ssbh_string
      - id: pixel_shader
        type: ssbh_string
      - id: compute_shader
        type: ssbh_string
  shader_program:
    doc: |
      0x50 bytes (version 1.0) or 0x60 bytes (version 1.1, adds
      vertex_attributes after the shader stages), relative to the programs
      array's own element base.
    seq:
      - id: name
        type: ssbh_string
      - id: render_pass
        type: ssbh_string
      - id: shaders
        type: shader_stages
  vertex_attribute:
    doc: 0x10 bytes. V1 program layout only.
    seq:
      - id: name
        type: ssbh_string
      - id: attribute_name
        type: ssbh_string
  material_parameter:
    doc: 0x18 bytes (last 8 bytes are padding the reference reader explicitly skips).
    seq:
      - id: param_id
        type: u8
        doc: One of lib-numatb.c's matl_param_names ids.
      - id: parameter_name
        type: ssbh_string
      - id: padding
        size: 8
