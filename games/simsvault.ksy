meta:
  id: simsvault
  title: EA Redwood Shores VALT attribute vault (.vlt)
  file-extension: vlt
  endian: le
doc: |
  SimAnimals, MySims Kingdom/Agents. Keys are FNV-1 32 over the lowercased
  name. Version 3: u32 type count at 0x14, 24-byte type table from 0x28
  {u32 key, u16 size, u16 flags, u16 alignment, u16 member count, ...}.
  Classes follow (32-byte header + fields: 16 bytes in v2, 24 in v3); the
  detailed class/field walk is not modelled.
seq:
  - id: one
    type: u4
  - id: magic
    contents: VALT
  - id: version
    type: u4
    doc: 2 SimAnimals, 3 MySims.
  - id: size
    type: u4
  - id: class_count
    type: u4
  - id: type_count
    type: u4
    if: version == 3
