meta:
  id: black_sheep_bgc
  title: Black Sheep Studio image set (.bgc)
  file-extension: bgc
  endian: be
doc: |
  Black Sheep Studio `.bgc` (Happy Neuron Academy `DataBase/**/*.bgc`). Each
  image is a GX RGBA8 texture (4x4 tiles, AR then GB planes); frames are spaced
  `size + 0x800` apart. The last two record fields are of unknown meaning.
seq:
  - id: magic
    contents: [0xfe, 0xed, 0xfe, 0xed]
  - id: one
    type: u4
  - id: num_records
    type: u4
  - id: len_table
    type: u4
    doc: 28 * num_records.
  - id: one_u2
    type: u2
  - id: signature
    size: 14
    type: strz
    encoding: ASCII
    doc: '".Black-Sheep."'
  - id: records
    type: record
    repeat: expr
    repeat-expr: num_records
types:
  record:
    seq:
      - id: id
        type: u4
        doc: Hash.
      - id: width
        type: u4
      - id: height
        type: u4
      - id: len_data
        type: u4
        doc: width * height * 4.
      - id: offset
        type: u4
      - id: unknown0
        type: u4
        doc: 12 (13 in Loading.bgc).
      - id: unknown1
        type: u4
        doc: 2 (0 in Loading.bgc).
