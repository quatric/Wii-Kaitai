meta:
  id: gripres
  file-extension: res
  endian: be
  title: Grip Entertainment "res" resource package (Sesame Street: Elmo's Musical Monsterpiece, Wii)
doc: |
  Big-endian serialised resource image used by Grip Entertainment's Wii
  titles. A small header points at a type table and a section table (the
  latter always at the end of the file); each section carries a 4-byte
  type tag, and is interpreted specially when that tag is "strg" (a
  NUL-separated name blob) or "indx" (the public resource index).
  Everything else (surf, gshd, bmsh, ...) is exported as a raw section.
  Ported from lib-gripres.c's `ScanGripRES`.
seq:
  - id: magic
    contents: "res\n"
  - id: version
    type: u4
    doc: Always 0x0c010500 in known samples.
  - id: unknown_08
    size: 4
  - id: data_base
    type: u4
    doc: Absolute offset of the first section; all section offsets are relative to this.
  - id: unknown_10
    size: 0x1c
  - id: ofs_table
    type: u4
    doc: Absolute offset of the section table (at the end of the file).
  - id: len_table
    type: u4
    doc: Byte size of the section table; `ofs_table + len_table` equals the file size.
  - id: unknown_34
    size: 8
  - id: num_types
    type: u4
  - id: types
    type: type_entry
    repeat: expr
    repeat-expr: num_types
instances:
  section_table:
    pos: ofs_table
    size: len_table
    type: section_table
types:
  type_entry:
    seq:
      - id: fourcc
        type: str
        size: 4
        encoding: ASCII
      - id: id
        type: u2
      - id: reserved
        type: u2
  section_table:
    seq:
      - id: num_sections
        type: u4
      - id: unknown_04
        type: u4
        doc: Always 4 in known samples.
      - id: sections
        type: section
        repeat: expr
        repeat-expr: num_sections
  section:
    seq:
      - id: fourcc
        type: str
        size: 4
        encoding: ASCII
        doc: |
          Section type tag; bytes outside the printable ASCII range are
          replaced with spaces and the tag is right-trimmed by the reader.
      - id: ofs_body
        type: u4
        doc: Offset of the section body, relative to `data_base`.
      - id: len_body
        type: u4
      - id: align
        type: u4
      - id: count
        type: u4
      - id: extra
        type: u4
    instances:
      body:
        io: _root._io
        pos: _root.data_base + ofs_body
        size: len_body
  indx_entry:
    doc: |
      One public-resource record inside an "indx" section. `name_rel` is a
      signed byte offset from this record's own file address to a
      NUL-terminated name string elsewhere in the file.
    seq:
      - id: name_rel
        type: s4
      - id: fourcc
        type: str
        size: 4
        encoding: ASCII
      - id: ofs_body
        type: u4
