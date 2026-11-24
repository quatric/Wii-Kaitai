meta:
  id: serz_geo
  title: Ubisoft/Kuju SERZ geometry (.GeoWii)
  file-extension: geowii
  endian: le
doc: |
  Same token stream as serz_tg plus {0xff 'R', name, u32} and {0xff 'A', name,
  type, u8 count, values}; 'p' and 'R' tokens also take an entity number
  (entities are 0-based in compact references; a compact 'p' carries no
  payload). One cHcPrimitiveSetDescWii holds a big-endian vertex-array blob
  (array 0 positions 3 x f32, array 1 normals 3 x f32 or colours 4 bytes,
  then texcoords 2 x f32) at ArrayOffset/ArraySize and a GX display list blob
  (0x80 quads, 0x90 triangles, 0x98 strip, 0xA0 fan, u16 vertex count, then one
  big-endian u16 index per array column, 3-5 columns).
seq:
  - id: magic
    contents: SERZ
  - id: version
    type: u4
  - id: stream
    size-eos: true
types:
  display_list_cmd:
    seq:
      - id: opcode
        type: u1
        doc: 0x80 quads, 0x90 triangles, 0x98 strip, 0xA0 fan.
      - id: vertex_count
        type: u2be
