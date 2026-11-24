meta:
  id: muranms
  title: Muramasa The Demon Blade .nms message sheet (NMSB inside FCMP)
  file-extension: nms
  endian: le
doc: Strings are Shift-JIS in Japanese sheets, Latin-1 in European ones; slots are zero on disc.
seq:
  - id: magic
    contents: NMSB
  - id: payload_size
    type: u4
  - id: header_size
    type: u4
    doc: 0x20.
  - id: zero0
    type: u4
  - id: zero1
    type: u4
  - id: string_count
    type: u4
  - id: pad
    size: 0x20 - 0x18
  - id: slots
    type: u4
    repeat: expr
    repeat-expr: string_count
  - id: strings
    size-eos: true
