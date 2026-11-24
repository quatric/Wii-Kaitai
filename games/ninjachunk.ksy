meta:
  id: ninjachunk
  title: Sega Ninja chunk model (.nj, Radirgy Noa Wii)
  file-extension: nj
  endian: be
doc: |
  Wii port stores tags byte reversed ("MCJN" / "LTJN") with big-endian fields. A
  .nj is "LTJN" (NJTL texture list: {u32 size}, body {u32 array offset, u32
  count}, entries {u32 name offset, attr, ptr}), optional "0FOP", and "MCJN"
  {u32 size} + object data. Object node (0x34): {u32 eval flags, u32 model, f32
  pos[3], i32 ang[3] (BAMS, 65536 = 360 deg), f32 scl[3], u32 child, u32
  sibling}; flags 1 no position, 2 no rotation, 4 no scale, 0x20 ZYX order.
  Model: {u32 vertex list, u32 polygon list, f32 center[3], f32 radius}. Vertex
  chunks (types 32..50) {head, u16 size in u32, u16 index offset, u16 count,
  vertices} 12/16/24/28 bytes per vertex.
seq:
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: tag
        size: 4
        type: str
        encoding: ASCII
      - id: size
        type: u4
      - id: body
        size: size
  node:
    seq:
      - id: eval_flags
        type: u4
      - id: model
        type: u4
      - id: position
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: angles
        type: s4
        repeat: expr
        repeat-expr: 3
      - id: scale
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: child
        type: u4
      - id: sibling
        type: u4
  model:
    seq:
      - id: vertex_list
        type: u4
      - id: polygon_list
        type: u4
      - id: center
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: radius
        type: f4
