meta:
  id: iga
  title: Alchemy/Vicarious Visions IGA archive (Skylanders)
  file-extension: arc
  endian: le
doc: |
  Alchemy / Vicarious Visions "IGA" archive (`.arc`; Skylanders on Wii),
  verified on retail Spyro's Adventure archives.

  After the 0x30-byte header come `count` sorted name hashes, then `count`
  `{offset, size, flags}` records (`flags == -1` means stored). At
  `names_offset` is a `u4 name_offset[count]` array (relative to
  `names_offset`) pointing into the string pool that follows; entry *i* uses
  name *i*.
seq:
  - id: magic
    contents: ['IGA', 0x1a]
  - id: version
    type: u4
    doc: Always 4.
  - id: toc_size
    type: u4
  - id: count
    type: u4
  - id: unknown_10
    type: u4
  - id: unknown_14
    type: u4
  - id: names_offset
    type: u4
  - id: names_size
    type: u4
  - id: reserved
    size: 16
  - id: name_hashes
    type: u4
    repeat: expr
    repeat-expr: count
    doc: Sorted.
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
instances:
  name_offsets:
    pos: names_offset
    type: u4
    repeat: expr
    repeat-expr: count
    doc: Relative to `names_offset`.
types:
  entry:
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: flags
        type: s4
        doc: -1 = stored.
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
