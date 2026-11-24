meta:
  id: vddbstr
  title: Dancing Dots VDDB string database
  file-extension: vddb
  endian: be
doc: |
  Header holds more relocation fields that are not decoded. The pool is a run
  of {key: NUL-terminated ASCII padded to 4, text: UTF-16BE with 0x0000
  terminator padded to 4; empty text omitted}.
seq:
  - id: magic
    contents: [0xdd, 0xdb]
  - id: version
    type: u2
    doc: 6.
  - id: x7d
    type: u4
  - id: name
    size: 0x34 - 8
    type: strz
    encoding: ASCII
  - id: string_count
    type: u4
  - id: unk38
    size: 8
  - id: pool_offset
    type: u4
    doc: At 0x40... read via instance.
instances:
  pool:
    pos: pool_offset
    size-eos: true
