meta:
  id: nttmodel
  file-extension: model
  endian: be
  title: "TT Games NTT engine model (LEGO Star Wars: The Skywalker Saga)"
doc: |
  TT Games NTT engine `.model` container. A chunked container of
  big-endian resource chunks, each holding a 12-byte type tag
  (`.CC4HSERHSER` hierarchy, `.CC4HSER2CSG` scene data) with all
  vertex/index payloads in little-endian buffers. Ported from
  `lib-nttmodel.c`/`.h`, whose layout itself is ported from
  KillzXGaming/NTT-Model-Dumper's `Model.cs`.

  The scene chunk's material and mesh tables (materials, then
  sub-meshes with DXTV vertex buffers and an index list) are not fully
  modelled here -- only the outer chunk framing and the well-understood
  DXTV vertex-buffer header, matching the reference decoder's own bounds
  -checked, best-effort parsing rather than a fixed schema.
seq:
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: size
        type: u4
        doc: Excludes this field's own 4 bytes; next chunk is at pos+size+4.
      - id: chunk_type
        type: str
        size: 12
        encoding: ASCII
        doc: '".CC4HSERHSER" (hierarchy) or ".CC4HSER2CSG" (scene data).'
      - id: version
        type: u4
      - id: payload
        size: size - 16
  hierarchy_chunk:
    doc: |
      Body of a ".CC4HSERHSER" chunk: three consecutive NUL-terminated
      strings.
    seq:
      - id: name1
        type: strz
        encoding: ASCII
      - id: name2
        type: strz
        encoding: ASCII
      - id: name3
        type: strz
        encoding: ASCII
  dxtv_buffer_header:
    doc: |
      Leading fields of a DXTV vertex buffer within a scene chunk (see
      lib-nttmodel.c ntt_validate_buffer / attribute table parsing). Each
      attribute table entry is 3 bytes (type, format, offset); the
      interleaved little-endian vertex data and a 16-byte footer follow
      immediately after, sized per-attribute using the format's stride
      (see ntt_stride_of in lib-nttmodel.c).
    seq:
      - id: magic
        contents: "DXTV"
      - id: unk1
        type: u4
      - id: num_attrs
        type: u4
      - id: attrs
        type: dxtv_attr
        repeat: expr
        repeat-expr: num_attrs
  dxtv_attr:
    doc: 3 bytes.
    seq:
      - id: attr_type
        type: u1
        doc: |
          0 position, 1 normal, 2 color0, 3 tangent, 4 color1,
          5 uv0/uv1, 6 unk, 7 uv2, 8 unk, 9 blend_index, 10 blend_weight,
          11 unk, 12 light_dir, 13 light_color.
      - id: attr_format
        type: u1
        doc: |
          2 vec2f, 3 vec3f, 4 vec4f, 5 vec2h, 6 vec4h, 7 vec4b,
          8 vec4bf, 9 color4b.
      - id: attr_offset
        type: u1
