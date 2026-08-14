meta:
  id: brres_sub_header
  endian: be
  title: NW4R BRRES sub-file common header
doc: |
  The 16-byte header every BRRES sub-file starts with (MDL0, TEX0, PLT0,
  CHR0, CLR0, PAT0, SRT0, SHP0, VIS0, SCN0 ...), plus the section-offset
  table that follows it.

  `ofs_brres` is the distance back to the start of the enclosing `bres`
  file, stored negative. For a sub-file extracted to its own file it is
  meaningless, but inside a container it is an exact self-check: it must
  equal `-(offset of this sub-file)`. Verified on every TEX0, PLT0, MDL0,
  CHR0 and VIS0 in the Animal Crossing: City Folk sample set.
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
    doc: Four-character sub-file type, e.g. `MDL0`, `TEX0`, `PLT0`.
  - id: len_file
    type: u4
    doc: |
      Size of this sub-file in bytes, header included. Sub-files sit
      back-to-back in the container, so this doubles as the stride to the
      next one.
  - id: version
    type: u4
    doc: |
      Format revision of this sub-file type, independent per type. It
      selects how many entries `ofs_section` has and, for MDL0, which
      section index means what.
  - id: ofs_brres
    type: s4
    doc: Negative offset back to the enclosing BRRES header; 0 when standalone.
