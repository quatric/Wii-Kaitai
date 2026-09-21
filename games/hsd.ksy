meta:
  id: hsd
  file-extension: dat
  endian: be
  title: HAL Laboratory "sysdolphin" (HSD) .dat archive
doc: |
  Serialized object-graph container used by Super Smash Bros. Melee, Kirby
  Air Ride and the Wii channel "Terebi no Tomo"/"TV no Tomo" (JPN). Not a
  directory-style archive: a flat blob of C structs starts at the 0x20 data
  base, and every inter-struct pointer is stored as an offset relative to
  that base, patched at load time via an explicit relocation table.

  Only the header, relocation table, root/reference tables and string pool
  are modeled here -- the data section itself is an untyped object graph
  (JOBJ/DOBJ/POBJ trees, textures, etc.) that needs the relocation table to
  even be walked, so it is exposed as raw bytes. Ported from lib-hsd.c's
  `IsHSD`/`ScanHSD` and the header comment in lib-hsd.h.
seq:
  - id: file_size
    type: u4
    doc: Equals the real file size.
  - id: ofs_reloc_table
    type: u4
    doc: Relocation table offset, relative to the 0x20 data base.
  - id: num_reloc
    type: u4
  - id: num_root
    type: u4
  - id: num_ref
    type: u4
  - id: version
    type: str
    size: 4
    encoding: ASCII
    doc: e.g. "001B".
  - id: reserved
    size: 8
  - id: data
    size: ofs_reloc_table
    doc: |
      Object-graph data section; every pointer inside it is a 0x20-relative
      offset, resolved through `reloc_table` rather than stored directly.
instances:
  reloc_table_pos:
    value: 0x20 + ofs_reloc_table
  reloc_table:
    pos: reloc_table_pos
    type: reloc_entry
    repeat: expr
    repeat-expr: num_reloc
  root_table:
    pos: reloc_table_pos + 4 * num_reloc
    type: node_ref
    repeat: expr
    repeat-expr: num_root
  ref_table:
    pos: reloc_table_pos + 4 * num_reloc + 8 * num_root
    type: node_ref
    repeat: expr
    repeat-expr: num_ref
types:
  reloc_entry:
    doc: |
      One 0x20-relative offset naming a location that holds a pointer; the
      u32 stored at that location is itself a 0x20-relative offset of the
      pointed-to struct.
    seq:
      - id: ofs_location
        type: u4
  node_ref:
    doc: A root node or external reference: an object offset paired with its name-string offset.
    seq:
      - id: ofs_node
        type: u4
        doc: 0x20-relative offset of the referenced struct.
      - id: ofs_name
        type: u4
        doc: Offset into the string pool of this reference's NUL-terminated name.
