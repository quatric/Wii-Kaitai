meta:
  id: simsvault
  title: EA Redwood Shores VALT attribute vault (.vlt)
  file-extension: vlt
  endian: be
params:
  - id: mode
    type: u1
    doc: |
      v3 only. Which two of the three trailing field words are the type index
      and the constraint count: 0 = type index in w3 position `b` (second word)
      and constraint count `cq` (third); 1 = type index `a` (first word) and
      constraint count `b` (second). nintoolbox decides by trying both and
      keeping the one whose class walk ends exactly at the end of the file.
doc: |
  SimAnimals, SimAnimals Africa, MySims Kingdom/Agents (Wii, big endian). Keys
  are FNV-1 32 (h = 0x811c9dc5; h *= 0x01000193; h ^= c) over the lowercased
  name.

  Layout: {u32 1, "VALT", u32 version, u32 size, u32 class count}. v3 has the
  type count at 0x14 and a 24-byte type table from 0x28, followed per type by
  its member keys (u32 each), member type indices (u16 each) and member counts
  (u16 each). Then one runtime pointer per class (v2: pointers start at 0x24)
  and the classes: a 32-byte header {u32 key, u32 0x20, u16 field count, ...}
  and its fields (16 bytes in v2, 24 in v3), then in v3 8 bytes per constraint
  record. Field flag 0x10 = array. Not validated on a real vault (none locally);
  the layout follows the nintoolbox extractor, which reads the same fields.
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
  - id: unk18
    size: 16
    if: version == 3
  - id: type_table
    type: type_entry
    repeat: expr
    repeat-expr: type_count
    if: version == 3
  - id: type_members
    type: type_members(_index)
    repeat: expr
    repeat-expr: type_count
    if: version == 3
  - id: v2_pad
    size: 16
    if: version == 2
  - id: class_pointers
    type: u4
    repeat: expr
    repeat-expr: class_count
  - id: classes
    type: class_def
    repeat: expr
    repeat-expr: class_count
types:
  type_entry:
    doc: 24-byte type record (v3).
    seq:
      - id: key
        type: u4
      - id: size
        type: u2
      - id: flags
        type: u2
      - id: alignment
        type: u2
      - id: member_count
        type: u2
      - id: rest
        size: 12
  type_members:
    params:
      - id: ti
        type: s4
    instances:
      n:
        value: _root.type_table[ti].member_count
    seq:
      - id: keys
        type: u4
        repeat: expr
        repeat-expr: n
      - id: type_indices
        type: u2
        repeat: expr
        repeat-expr: n
      - id: counts
        type: u2
        repeat: expr
        repeat-expr: n
  class_def:
    seq:
      - id: header
        type: class_header
      - id: fields_v2
        type: field_v2
        repeat: expr
        repeat-expr: header.field_count
        if: _root.version == 2
      - id: fields_v3
        type: field_node(_root.mode, header.field_count, 0)
        if: _root.version == 3 and header.field_count > 0
        doc: First of a chain of field_count nodes; the last one also holds the constraint records.
  class_header:
    doc: 32 bytes per class.
    seq:
      - id: key
        type: u4
      - id: x20
        type: u4
      - id: field_count
        type: u2
      - id: rest
        size: 22
  field_v2:
    seq:
      - id: key
        type: u4
      - id: type
        type: u4
      - id: size
        type: u2
      - id: flags
        type: u2
      - id: count
        type: u2
      - id: alignment
        type: u2
  field_node:
    params:
      - id: mode
        type: u1
      - id: remaining
        type: s4
      - id: acc
        type: s4
        doc: Constraint records counted by the fields before this one.
    seq:
      - id: key
        type: u4
      - id: type
        type: u4
      - id: size
        type: u2
      - id: flags
        type: u2
      - id: count
        type: u2
      - id: wa
        type: u2
      - id: wb
        type: u2
      - id: wc
        type: u2
      - id: unk20
        size: 4
      - id: constraints
        size: 8 * (acc + constraints_here)
        if: remaining == 1
        doc: 8-byte constraint records for the whole class, after the last field.
      - id: next
        type: field_node(mode, remaining - 1, acc + constraints_here)
        if: remaining > 1
    instances:
      type_index:
        value: 'mode == 1 ? wa : wb'
      constraints_here:
        value: 'mode == 1 ? wb : wc'
