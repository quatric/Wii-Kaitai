meta:
  id: tgstex
  title: Muscle Impact .tgs texture container
  file-extension: tgs
  endian: be
doc: A standard Wii TPL (magic 0x0020AF30) follows the header, then a short tail.
seq:
  - id: magic
    contents: ["tgs", 0]
  - id: three
    type: u4
  - id: zero0
    type: u4
  - id: file_size
    type: u4
  - id: x20_a
    type: u4
  - id: x20_b
    type: u4
  - id: zero1
    type: u4
  - id: tpl_offset
    type: u4
    doc: 0x40.
  - id: tpl_end
    type: u4
  - id: tail_end
    type: u4
  - id: pad
    size: 0x40 - 0x30
instances:
  tpl:
    pos: tpl_offset
    size: tpl_end - tpl_offset
  tail:
    pos: tpl_end
    size: tail_end - tpl_end
