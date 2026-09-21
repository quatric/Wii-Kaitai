meta:
  id: pgdat
  title: PlatinumGames DAT archive
  file-extension:
    - dat
    - pkz
  endian: le
  license: CC0-1.0

doc: |
  PlatinumGames engine flat file archive, magic "DAT\0". Holds parallel
  tables of file offsets, sizes, extensions and (optionally) names.

  Reference: nintoolbox project/src/lib-pgdat.c (ExtractPGDATArchive).

seq:
  - id: magic
    contents: [0x44, 0x41, 0x54, 0x00]
  - id: file_count
    type: u4
  - id: offset_file_offset_tbl
    type: u4
  - id: offset_file_ext_tbl
    type: u4
  - id: offset_file_name_tbl
    type: u4
  - id: offset_file_size_tbl
    type: u4

instances:
  name_tbl_stride:
    pos: offset_file_name_tbl
    type: u4
    if: offset_file_name_tbl != 0
  offsets:
    pos: offset_file_offset_tbl
    type: u4
    repeat: expr
    repeat-expr: file_count
  sizes:
    pos: offset_file_size_tbl
    type: u4
    repeat: expr
    repeat-expr: file_count
  exts:
    pos: offset_file_ext_tbl
    type: u4
    repeat: expr
    repeat-expr: file_count
    if: offset_file_ext_tbl != 0
  names:
    doc: |
      Present only when offset_file_name_tbl != 0. name_tbl_stride is a u32
      giving the fixed per-entry name length; names[i] occupies
      offset_file_name_tbl + 4 + i * name_tbl_stride, each a fixed-width
      (possibly NUL-padded) string.
    pos: offset_file_name_tbl + 4
    type: str
    size: name_tbl_stride
    encoding: ASCII
    repeat: expr
    repeat-expr: file_count
    if: offset_file_name_tbl != 0
