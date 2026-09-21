meta:
  id: byml
  file-extension:
    - byml
    - bym
  title: Nintendo BYML binary YAML
doc: |
  Nintendo's compact binary encoding of a YAML-like document tree, used
  across many first-party titles (Super Mario 3D World/Land, Splatoon,
  Breath of the Wild and others) for stage/actor/parameter data.

  The file starts with a 2-byte magic that also announces the byte order
  ("BY" for big-endian, "YB" for little-endian), a version, and three
  table offsets: a hash-key string pool, a plain string pool, and the root
  node. Newer variants (version >= 3, seen from Wii U/Switch titles) may
  additionally carry a path-array table between the string tables and the
  root node.

  Every container node (array/map/hashmap) stores its type byte followed
  by a 24-bit element count, then a value slot per element; a value slot
  is either the value inlined (bool/int/float/uint) or a 32-bit offset to
  where the value is stored (string, binary, nested container, 64-bit
  numbers). This definition covers the header and the two string tables;
  the recursively-typed node graph is intentionally not fully unrolled
  here because its shape depends on run-time type tags at each offset,
  which is beyond a static struct definition.
seq:
  - id: magic
    type: str
    size: 2
    encoding: ASCII
    valid:
      any-of: ['"BY"', '"YB"']
    doc: '"BY" = big-endian, "YB" = little-endian.'
  - id: version
    type: u2
    doc: Format version, observed range 1..7.
  - id: ofs_hash_key_table
    type: u4
    doc: Offset to the hash-key string table (used by hashmap containers), or 0.
  - id: ofs_string_table
    type: u4
    doc: Offset to the plain string table (used by string-valued nodes), or 0.
  - id: ofs_root_node
    type: u4
    doc: |
      Offset to the root container node. On files that also carry a path
      table (detected heuristically by the reader, not by a flag), this
      field instead holds the path-array table offset and the root node
      offset follows as a fourth u4.
types:
  string_table:
    doc: |
      A BYML string-pool container: type byte 0xC2, a 24-bit count, then
      count+1 u4 offsets (relative to the table start) marking the start
      of each NUL-terminated string plus a trailing end marker.
    seq:
      - id: type
        type: u1
        valid: 0xc2
      - id: count
        type: b24
      - id: ofs_entry
        type: u4
        repeat: expr
        repeat-expr: count + 1
