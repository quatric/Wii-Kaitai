meta:
  id: pack
  endian: be
  title: Wii/GameCube PACK archive
doc: |
  Generic "PACK" flat archive used by several Wii/GameCube titles, as
  read by IterateFilesPACK() in lib-pack.c (`pack_header_t`/
  `pack_metric_t` in lib-pack.h). A fixed header points to a metric
  table of (offset, size) pairs; subfile names live in a name pool
  directly after the header.
seq:
  - id: magic
    contents: "PACK"
  - id: file_size
    type: u4
  - id: num_files
    type: u4
  - id: offset_metric
    type: u4
    doc: Offset to the (offset,size) metric table.
instances:
  metrics:
    type: metric
    repeat: expr
    repeat-expr: num_files
    pos: offset_metric
types:
  metric:
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
