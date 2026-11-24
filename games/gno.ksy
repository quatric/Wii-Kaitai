meta:
  id: gno
  title: Sega Ninja GC model (.gno / .gnm / .gnj / .gnt / .gnv / .gnf)
  file-extension: gno
  endian: be
doc: |
  Chunks {tag[4], u32 LE size (without the 8-byte head), body}: "NGIF"
  ({u32 0x18 LE, chunk count, 0x20, sizes}), "NGTL" (texture list: 20-byte
  records + file names), "NGOB" / "NGMO" (object data), "NOF0" ({u32 BE count,
  0, offsets relative to 0x20 of every pointer}), "NFN0" (file name), "NEND".
  Pointers are relative to 0x20. Vertex arrays are 0x38-byte groups of 8-byte
  slots {u16 kind, u16 count, u32 ptr}: slot 0 positions (3 floats), 1 normals
  (3 s8, 1/64), 3 texcoords (2 s16, 1/128).
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
        type: u4le
      - id: body
        size: size
  vertex_slot:
    seq:
      - id: kind
        type: u2
      - id: count
        type: u2
      - id: ptr
        type: u4
