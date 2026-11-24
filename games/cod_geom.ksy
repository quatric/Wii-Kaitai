meta:
  id: cod_geom
  title: Call of Duty World at War geometry (.xgm / .sgm)
  endian: be
doc: |
  Raw in-memory image: u16 magic 0x4321, u16 version 1, u32 fixup count N, then
  N {u32 location, u32 target} pairs (the engine writes base + target into the
  word at base + location). Vertex arrays are 0x20-byte declarations {u16 1, u16
  element count, 0, u8 stride, u8 1, u16 GQR style word (low 3 bits type: 7 s16,
  6 s8, 5 u16, 4 u8, 0 f32; bits 8..13 fraction bits), ..., name pointer at +0x18
  ("Position", "Normal", "TexCoord", "Color", "Lightmap"), data pointer at
  +0x1c}. A draw is {u32 attribute count, u32 attribute table size, attribute
  table pointer, 0, display list pointer, u32 display list size}; table entries
  are 8 bytes {u8 GX attribute (9 position, 10 normal, 11 colour, 13+ texcoords),
  0, 0, u8 stride, array pointer}; the display list is GX draw commands.
seq:
  - id: magic
    contents: [0x43, 0x21]
  - id: version
    type: u2
  - id: fixup_count
    type: u4
  - id: fixups
    type: fixup
    repeat: expr
    repeat-expr: fixup_count
  - id: image
    size-eos: true
types:
  fixup:
    seq:
      - id: location
        type: u4
      - id: target
        type: u4
  declaration:
    seq:
      - id: one
        type: u2
      - id: element_count
        type: u2
      - id: zero
        type: u4
      - id: stride
        type: u1
      - id: one_b
        type: u1
      - id: gqr_style
        type: u2
      - id: unk
        size: 0x18 - 0x0c
      - id: name_ptr
        type: u4
      - id: data_ptr
        type: u4
  draw:
    seq:
      - id: attribute_count
        type: u4
      - id: attribute_table_size
        type: u4
      - id: attribute_table_ptr
        type: u4
      - id: zero
        type: u4
      - id: display_list_ptr
        type: u4
      - id: display_list_size
        type: u4
  attribute:
    seq:
      - id: gx_attribute
        type: u1
      - id: zero
        size: 2
      - id: stride
        type: u1
      - id: array_ptr
        type: u4
