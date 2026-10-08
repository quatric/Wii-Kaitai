meta:
  id: dc2_dcm
  title: Speed 2 "DC2" container model (.dcm)
  file-extension: dcm
  endian: be
doc: |
  `DC2\0` container models of Speed 2 (Wii). Big-endian floats follow a
  descriptor header whose layout is not documented by nintoolbox; the decoder
  scans from 0x30 for a **position / normal / texcoord** triple of
  length-prefixed vertex-array blocks and accepts only files with exactly one
  such triple. The triple is followed (within 64 bytes) by a stream of
  triangle-strip records, `0x9b` opcodes. Strip winding was verified against
  the stored normals.

  Because the header size is not fixed, this definition exposes the block and
  strip types for you to apply at the scanned positions; `vertex_block(12)` is
  used for positions and normals, `vertex_block(8)` for texcoords.
seq:
  - id: magic
    contents: ['DC2', 0]
  - id: rest
    size-eos: true
types:
  vertex_block:
    params:
      - id: stride
        type: u1
    seq:
      - id: zero
        type: u4
      - id: stride_stored
        type: u1
        valid: stride
      - id: count
        type: u4
      - id: data
        size: count * stride
        doc: Big-endian f4 triples (stride 12) or pairs (stride 8).
  strip_stream:
    seq:
      - id: strips
        type: strip
        repeat: until
        repeat-until: _io.eof or _.opcode != 0x9b
  strip:
    seq:
      - id: opcode
        type: u1
        doc: 0x9b.
      - id: count
        type: u2
        if: opcode == 0x9b
      - id: vertices
        type: strip_vertex
        repeat: expr
        repeat-expr: count
        if: opcode == 0x9b
  strip_vertex:
    seq:
      - id: position
        type: u2
      - id: normal
        type: u2
      - id: texcoord
        type: u2
