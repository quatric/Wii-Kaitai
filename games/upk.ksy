meta:
  id: upk
  title: Unreal Engine 1/2 package (version 0x84, Surf's Up)
  file-extension: upk
  endian: le
doc: |
  Offsets are relative to the package start; a file may hold many packages back
  to back. Names are {u8 len, text NUL, u32 flags}; imports and exports use
  Unreal compact-index integers (not modelled), exports {class, super, outer,
  name, flags, size, offset}.
seq:
  - id: magic
    contents: [0xc1, 0x83, 0x2a, 0x9e]
  - id: version_licensee
    type: u4
  - id: flags
    type: u4
  - id: name_count
    type: u4
  - id: name_offset
    type: u4
  - id: export_count
    type: u4
  - id: export_offset
    type: u4
  - id: import_count
    type: u4
  - id: import_offset
    type: u4
instances:
  names:
    pos: name_offset
    type: name
    repeat: expr
    repeat-expr: name_count
types:
  name:
    seq:
      - id: len
        type: u1
      - id: text
        size: len
        type: strz
        encoding: ASCII
      - id: flags
        type: u4
