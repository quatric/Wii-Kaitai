meta:
  id: upk
  title: Unreal Engine 1/2 package (version 0x84, Surf's Up)
  file-extension: upk
  endian: le
doc: |
  Offsets are relative to the package start; a file may hold many packages
  back to back. Names {u8 len, text NUL, u32 flags}; imports {pkg, class,
  i32 outer, name} and exports {class, super, i32 outer, name, u32 flags,
  size, offset} use Unreal compact-index integers.
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
  imports:
    pos: import_offset
    type: import_entry
    repeat: expr
    repeat-expr: import_count
  exports:
    pos: export_offset
    type: export_entry
    repeat: expr
    repeat-expr: export_count
types:
  compact_index:
    doc: |
      First byte: bit 7 sign, bit 6 continuation, low 6 bits value; each
      following byte: bit 7 continuation, low 7 bits value.
    seq:
      - id: first
        type: u1
      - id: rest
        type: u1
        repeat: until
        repeat-until: (_ & 0x80) == 0
        if: (first & 0x40) != 0
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
  import_entry:
    seq:
      - id: package
        type: compact_index
      - id: class_name
        type: compact_index
      - id: outer
        type: s4
      - id: name
        type: compact_index
  export_entry:
    seq:
      - id: class_ref
        type: compact_index
      - id: super_ref
        type: compact_index
      - id: outer
        type: s4
      - id: name
        type: compact_index
      - id: flags
        type: u4
      - id: size
        type: compact_index
      - id: offset
        type: compact_index
