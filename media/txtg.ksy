meta:
  id: txtg
  endian: le
  title: Next Level Games Texture To Go (.txtg / 6PK0)
doc: |
  Next Level Games "Texture To Go" texture, per lib-txtg.c.
seq:
  - id: header_size
    type: u2
    doc: Usually 0x50.
  - id: version
    type: u2
    doc: Usually 0x11.
  - id: magic
    contents: "6PK0"
  - id: width
    type: u2
  - id: height
    type: u2
  - id: depth
    type: u2
  - id: mip_count
    type: u1
  - id: unknown1
    type: u1
  - id: unknown2
    type: u1
  - id: padding
    type: u1
  - id: format_flag
    type: u1
  - id: format_setting
    type: u4
  - id: unknown_17
    size: 0x44 - 0x17
  - id: format
    type: u2
  - id: unknown_46
    size: header_size - 0x46
  - id: surfaces
    size-eos: true
