meta:
  id: xb
  endian: be
  title: Nd Cube Binary XML (XB)
doc: |
  Nd Cube Binary XML format, per lib-xb.c (ported from
  MPLibrary/WiiU/BinaryXML.cs). Used in Mario Party 10, Animal
  Crossing: amiibo Festival, Wii Party U. The element/attribute tree
  that follows the header is a recursive, offset-tagged structure
  (terminated by 0xFFFF/0xFFFFFFFF sentinels depending on the
  declared value width) and is not expanded here.
seq:
  - id: magic
    contents: [0x58, 0x42]
  - id: flags
    type: u2
    doc: Low byte selects value width -- 0x4C = u32 offsets, 0x53 = u16 offsets.
  - id: body
    size-eos: true
instances:
  value_type:
    value: flags & 0xff
