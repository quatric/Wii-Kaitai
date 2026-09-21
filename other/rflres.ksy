meta:
  id: rflres
  endian: be
  title: Nintendo Mii Face Library resource archive (RFL_Res / FFL_Res / CFL_Res)
doc: |
  Mii Face Library resource archive (RFL_Res.dat on Wii, FFL_Res.dat
  on Wii U/Switch, CFL_Res.dat on 3DS), per lib-rflres.c/.h. Carries
  no magic: a top-level offset table of sub-archives, each itself an
  offset table of files. Endianness (be for Wii/Wii U, le for 3DS/
  Switch) must be detected externally; this definition covers the
  big-endian (RFL/FFL) case. Every offset is absolute from the start
  of the file.
seq:
  - id: num_sub_archives
    type: u2
  - id: sub_archive_offsets
    type: u4
    repeat: expr
    repeat-expr: num_sub_archives
instances:
  sub_archives:
    type: sub_archive_t
    repeat: expr
    repeat-expr: num_sub_archives
    pos: sub_archive_offsets[_index]
types:
  sub_archive_t:
    seq:
      - id: num_files
        type: u2
      - id: file_offsets
        type: u4
        repeat: expr
        repeat-expr: num_files + 1
        doc: One extra trailing offset marks the end of the last file.
