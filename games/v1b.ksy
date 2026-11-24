meta:
  id: v1b
  title: Nights Journey of Dreams v1b arrangement table
  file-extension: bin
  endian: be
seq:
  - id: magic
    contents: ["v1b", 0x20]
  - id: count
    type: u4
  - id: trailer_size
    type: u4
  - id: records
    type: record
    repeat: expr
    repeat-expr: count
  - id: trailer
    size: trailer_size
types:
  record:
    seq:
      - id: words
        size: 4
        repeat: expr
        repeat-expr: 15
        doc: Floats and ints, meaning undetermined.
