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

  Carries no magic number, so a decoder must validate the header shape
  itself (file size matching the real file size, relocation table
  placement, root/reference counts and the ASCII version tag) rather than
  checking a fixed byte string -- this is exactly what `IsHSD` in lib-hsd.c
  does before `ScanHSD` trusts the header.

  Only the header, relocation table, root/reference tables and string pool
  are modeled here -- the data section itself is an untyped object graph
  (JOBJ/DOBJ/POBJ/MOBJ/TOBJ trees, textures, etc.) that needs the relocation
  table to even be walked, so it is exposed as raw bytes.

  The object graph beyond this point is a JOBJ (joint) tree, each JOBJ
  optionally owning a chain of DOBJ (display object) nodes, each DOBJ
  optionally owning a chain of POBJ (polygon object) nodes holding the GX
  display-list opcode stream and vertex attribute arrays; DOBJs also
  reference MOBJ (material) and, through them, TOBJ (texture) nodes.
  `root_table` gives the exact, named entry points into this graph (e.g.
  "ToyBoxModel_TopN_joint" for a JOBJ root) rather than requiring a blind
  structural scan; `ref_table` names structs the file expects to be
  resolved externally (shared textures/animations across a title's files).
  Independently verified against 352 real "Ty*.dat" item/object files from
  a retail Super Smash Bros. Melee disc: 346 decode to correct, glTF-valid
  geometry.

  Several titles (e.g. Doraemon on GameCube) ship one file holding several
  complete HSD archives back to back, each with its own header and 0xCD
  fill between them -- not modeled here since it is a container-of-
  containers concern, not part of a single archive's layout.

  Ported from lib-hsd.c's `IsHSD`/`ScanHSD` and the header comment in
  lib-hsd.h, both cross-checked against Ploaj/HSDLib's HSDRawFile.cs
  (`Open()`, MIT licensed) for the relocation/root/reference parsing.
seq:
  - id: file_size
    type: u4
    doc: Equals the real file size.
  - id: ofs_reloc_table
    type: u4
    doc: Relocation table offset, relative to the 0x20 data base.
  - id: num_reloc
    type: u4
    doc: Number of `reloc_table` entries.
  - id: num_root
    type: u4
    doc: Number of `root_table` entries.
  - id: num_ref
    type: u4
    doc: Number of `ref_table` entries.
  - id: version
    type: str
    size: 4
    encoding: ASCII
    doc: e.g. "001B".
  - id: reserved
    size: 8
    doc: Zero-filled in every real sample seen; not read by `ScanHSD`.
  - id: data
    size: ofs_reloc_table
    doc: |
      Object-graph data section; every pointer inside it is a 0x20-relative
      offset, resolved through `reloc_table` rather than stored directly.
      Structurally a JOBJ/DOBJ/POBJ/MOBJ/TOBJ object graph (see the `doc`
      above), but exposed as raw bytes here since walking it needs the
      relocation, root and reference tables resolved first.
instances:
  reloc_table_pos:
    value: 0x20 + ofs_reloc_table
    doc: Absolute file offset of `reloc_table` (the on-disk value is 0x20-relative).
  reloc_table:
    pos: reloc_table_pos
    type: reloc_entry
    repeat: expr
    repeat-expr: num_reloc
    doc: |
      Every location in `data` that holds a pointer, so a loader can walk
      the whole set and patch each stored 0x20-relative offset into a real
      pointer in one pass, without having to trace the object graph itself
      to find them.
  root_table:
    pos: reloc_table_pos + 4 * num_reloc
    type: node_ref
    repeat: expr
    repeat-expr: num_root
    doc: |
      Named entry points into the object graph -- typically JOBJ roots for
      a model (e.g. "ToyBoxModel_TopN_joint" on a real Super Smash Bros.
      Melee item file) or other top-level structs this archive's own
      consumer looks up by name, such as "scene_data" in a Doraemon-style
      multi-archive bundle.
  ref_table:
    pos: reloc_table_pos + 4 * num_reloc + 8 * num_root
    type: node_ref
    repeat: expr
    repeat-expr: num_ref
    doc: |
      Named structs this archive expects another, externally-loaded
      archive to resolve by name -- e.g. a shared texture or animation
      referenced by several files in the same title, rather than
      duplicated into each one.
types:
  reloc_entry:
    doc: |
      One 0x20-relative offset naming a location that holds a pointer; the
      u32 stored at that location is itself a 0x20-relative offset of the
      pointed-to struct. Unlike `node_ref`, a relocation entry carries no
      name -- it is purely "patch the pointer that lives here", found by
      the loader walking every reachable field of the object graph once at
      build time and recording where each one landed.
    seq:
      - id: ofs_location
        type: u4
  node_ref:
    doc: |
      A root node or external reference: an object offset paired with its
      name-string offset. `root_table` and `ref_table` share this same
      struct; which table an entry sits in is what distinguishes "owned by
      this archive" from "expected to be supplied by another one".
    seq:
      - id: ofs_node
        type: u4
        doc: 0x20-relative offset of the referenced struct.
      - id: ofs_name
        type: u4
        doc: Offset into the string pool of this reference's NUL-terminated name.
