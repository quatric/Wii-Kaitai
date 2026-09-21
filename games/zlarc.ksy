meta:
  id: zlarc
  endian: be
  title: NES Remix indieszero archive (.zlarc)
doc: |
  NES Remix indieszero archive, per lib-zlarc.c. The whole file is a
  single zlib stream; this definition models the decompressed body.
seq:
  - id: raw
    size-eos: true
    process: zlib
    type: body_t
types:
  body_t:
    seq:
      - id: num_entries
        type: u4
      - id: descriptor_offsets
        type: u4
        repeat: expr
        repeat-expr: num_entries
    instances:
      descriptors:
        type: descriptor_t
        repeat: expr
        repeat-expr: num_entries
        pos: descriptor_offsets[_index]
  descriptor_t:
    seq:
      - id: data_offset
        type: u4
      - id: data_size
        type: u4
      - id: name_length
        type: u4
      - id: name
        type: str
        size: name_length
        encoding: UTF-8
    instances:
      body:
        pos: data_offset
        size: data_size
