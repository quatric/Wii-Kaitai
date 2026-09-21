meta:
  id: rbnk
  endian: be
  title: Nintendo NW4R RBNK instrument bank (Wii)
doc: |
  NW4R "RBNK" instrument bank, per lib-rbnk.c/.h. Models the fixed
  header and the DATA/WAVE ruint-list containers; the note-lookup
  tree inside DATA (RangeTable/IndexTable/InstParam, ported from
  BrawlLib) is recursive with offsets always relative to the top of
  the DATA ruint list, so it is left as a raw byte span here rather
  than reproduced -- see lib-rbnk.h for the documented tree-walk
  semantics. WAVE is only present for version-minor < 2 banks;
  version >= 2 references an embedded RWAR archive instead.
seq:
  - id: magic
    contents: "RBNK"
  - id: file_size
    type: u4
  - id: version_major
    type: u1
  - id: version_minor
    type: u1
  - id: unknown_08
    size: 8
  - id: data_off
    type: u4
  - id: unknown_14
    type: u4
  - id: wave_off
    type: u4
instances:
  data:
    pos: data_off
    type: ruint_list_section
    io: _io
  wave:
    pos: wave_off
    type: ruint_list_section
    io: _io
    if: wave_off != 0
types:
  ruint_list_section:
    seq:
      - id: magic
        size: 4
        doc: '"DATA" or "WAVE".'
      - id: section_size
        type: u4
      - id: num_entries
        type: u4
      - id: entries
        type: ruint
        repeat: expr
        repeat-expr: num_entries
  ruint:
    doc: 1-byte type tag + 3-byte offset, relative to the enclosing entries list.
    seq:
      - id: entry_type
        type: u1
        enum: entry_type_t
      - id: offset
        type: b24
enums:
  entry_type_t:
    0: invalid
    1: inst
    2: range
    3: index
    4: null_entry
