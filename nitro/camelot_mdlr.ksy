meta:
  id: camelot_mdlr
  title: Camelot Software Planning model definition (Golden Sun Dark Dawn .mdlr)
  file-extension: mdlr
  endian: le
doc: |
  `MDLR` model-definition container of Golden Sun: Dark Dawn (1,284 retail
  files, all identified by their header). Interactive 3D map props, puzzle
  interactables and animated scenery are described here.

  After the actor identifier, chunks follow immediately: `ANMC` (animation
  controller states such as `WAIT_S_1`, `ACT_A`, `LOOP`), `COLL` (collision,
  binding to `.col` meshes), `LCTR` (lighting / reflection controls) and
  `REND` (render activation tags). nintoolbox only detects the container;
  the chunk framing below is not documented there, so the chunk bodies are
  kept as raw bytes.
seq:
  - id: magic
    contents: 'MDLR'
  - id: delimiter
    contents: [0]
  - id: name_length
    type: u4
    doc: Byte length of the actor model name.
  - id: actor_name
    type: strz
    size: name_length
    encoding: ASCII
    doc: ASCII identifier, NUL-terminated.
  - id: chunks
    size-eos: true
    doc: '`ANMC` / `COLL` / `LCTR` / `REND` chunks.'
