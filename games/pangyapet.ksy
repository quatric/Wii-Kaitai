meta:
  id: pangyapet
  title: Pangya (Super Swing Golf) model (.pet / .mpet)
  endian: be
doc: |
  Chunk list {char tag[4], u32 size incl. 8-byte head} ("BONE", "MESH", ...). The
  MESH chunk holds from +0x1c a "grff" container {u32 0x20, "ffrg" "\0rmg", u32
  size, u32 5, u32 chunk count (+0x14), ...} with 16-byte chunk headers from
  +0x20 {tag stored reversed, u32 count, u32 element size, u32 offset}: "vbd",
  "vbh" {flags, size, offset}, "ibd", "ibh", "ved" {offset, type (2 float3, 1
  float2), usage (3<<16 normal, 5<<16 texcoord)}, "prm". 0x20-byte primitive:
  {.., u16 index count (+6), vertex count (+8), vertex stride (+0xa), 0x98 (GX
  triangle strip, +0xc), triangle count (+0xe), index buffer (+0x10, 0xffff =
  none), vertex buffer (+0x12)}.
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
        size: size - 8
  grff_chunk_header:
    seq:
      - id: tag
        size: 4
      - id: count
        type: u4
      - id: element_size
        type: u4
      - id: offset
        type: u4
