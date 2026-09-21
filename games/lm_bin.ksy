meta:
  id: lm_bin
  file-extension: bin
  application: Luigi's Mansion (GameCube)
  endian: be
doc: |
  Luigi's Mansion (GameCube) room/stage model, version 2. Ported from
  lib-lmbin.c/.h (re-implemented from KillzXGaming/MdlConverter's
  GCNLibrary/LM/BIN, MIT-licensed; model research by opeyx and
  SpaceCats). Only the fixed 64-byte header of section offsets is
  modeled here: everything past it (fixed-stride texture/sampler/
  material/shape-batch/scene-graph arrays, float/s16 vertex pools and
  GX display-list packets at opcodes 0x90/0x98/0xA0) has counts that
  are implicit, recovered only by walking the scene graph and draw
  elements, and is exposed here as opaque per-section byte spans.
seq:
  - id: version
    type: u1
    doc: Always 2 for this layout.
  - id: name
    type: str
    size: 11
    encoding: ASCII
    terminator: 0
  - id: texture_off
    type: u4
  - id: sampler_off
    type: u4
  - id: position_off
    type: u4
  - id: normal_off
    type: u4
  - id: attr1_off
    type: u4
    doc: Colour 0 attribute pool.
  - id: attr2_off
    type: u4
    doc: Colour 1 attribute pool.
  - id: uv_off
    type: u4
  - id: attr3_off
    type: u4
  - id: attr4_off
    type: u4
  - id: attr5_off
    type: u4
  - id: material_off
    type: u4
  - id: shape_batch_off
    type: u4
  - id: scene_graph_off
    type: u4
    doc: |
      Offset of scene-graph node 0 (140 bytes/node); the rest of the
      tree is reached by walking child/sibling links and draw-element
      indices from there, so no node count is stored in the header.
