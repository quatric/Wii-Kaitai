meta:
  id: baev
  title: Animation event archive (.baev, BFFH container)
  file-extension: baev
  endian: le
doc: |
  AnimationEventArchiveResData. 64-bit offsets, all absolute. BFFH header:
  magic, u32 0, u32 file size, u32 alignment, {u64 offset, u32 count, u32 size}
  section headers (BFSI: magic, u32 offset, u32 size, u32 alignment, u64 base,
  char name[16]; "Default" and "StringPool"), u64 container, char type[0x80].
  Container: u64, u8 sub, u8 minor, u16 major, u32, u64 string pool, then two
  arrays {u64 offset, u32 count, u32 entry size}: animations {u32 FNV-1a hash,
  u32, {u64, u32 count, u32 4} node indices} and nodes {u64 events, u32 count,
  u32 0x30, u32 hash, u32}. Event (0x30): u64 name, {u64, u32, u32 0x18}
  triggers, {u64, u32, u32 0x18} holds, u32 hold flag, u32 id. Parameter: u32
  type, u32 0, then u32 (0 int), f32 (1 float), 3 x f32 (3 vector) or u64 string
  (5).
seq:
  - id: magic
    size: 4
  - id: zero
    type: u4
  - id: file_size
    type: u4
  - id: alignment
    type: u4
  - id: sections
    type: section_header
    repeat: expr
    repeat-expr: 2
  - id: container_ptr
    type: u8
  - id: type_name
    size: 0x80
    type: strz
    encoding: ASCII
types:
  section_header:
    seq:
      - id: offset
        type: u8
      - id: count
        type: u4
      - id: size
        type: u4
  bfsi:
    seq:
      - id: magic
        size: 4
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: alignment
        type: u4
      - id: base
        type: u8
      - id: name
        size: 16
        type: strz
        encoding: ASCII
  container:
    seq:
      - id: unk0
        type: u8
      - id: version_sub
        type: u1
      - id: version_minor
        type: u1
      - id: version_major
        type: u2
      - id: unk
        type: u4
      - id: string_pool
        type: u8
      - id: animations
        type: array_ref
      - id: nodes
        type: array_ref
  array_ref:
    seq:
      - id: offset
        type: u8
      - id: count
        type: u4
      - id: entry_size
        type: u4
  event:
    seq:
      - id: name
        type: u8
      - id: triggers
        type: array_ref
      - id: holds
        type: array_ref
      - id: hold_flag
        type: u4
      - id: id
        type: u4
