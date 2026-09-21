meta:
  id: rainbow_gcg
  endian: be
  title: Rainbow Studios GCG geometry (Disney-Pixar Cars, GameCube/Wii)
doc: |
  Rainbow Studios engine ".gcg" geometry container, per lib-rainbow.h.
  Models only the fixed header up through the material-name table;
  the per-strip GX vertex-attribute descriptions, arrays and display
  lists that follow are variable-length and not modeled here.
seq:
  - id: magic
    contents: "gcg\0"
  - id: version
    type: u4
    doc: Always 5.
  - id: count
    type: u4
    doc: Always 1.
  - id: name
    type: str
    size: 0x80
    encoding: ASCII
    terminator: 0
  - id: matrix
    type: f4
    repeat: expr
    repeat-expr: 16
  - id: bounds
    type: f4
    repeat: expr
    repeat-expr: 7
  - id: separator
    contents: [0xff, 0xff, 0xff, 0xff]
  - id: material_count
    type: u4
  - id: material_names
    type: str
    size: 0x40
    encoding: ASCII
    terminator: 0
    repeat: expr
    repeat-expr: material_count
  - id: body
    size-eos: true
    doc: |
      Flags/colour, strip table (material index + GX vertex-attribute
      descriptions), vertex/colour/UV arrays and the GX display list
      itself; a variable-length bitstream not modeled here.
