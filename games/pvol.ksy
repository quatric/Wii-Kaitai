meta:
  id: pvol
  title: Pikmin 1 & 2 model/archive container
  file-extension: pvol
  endian: le
  license: CC0-1.0

doc: |
  Pikmin 1 & 2 (GameCube) flat file container. A file_count-1-entry table of
  {offset, length} pairs; each entry's data begins with a 0x28-byte name
  block (two NUL-padded strings concatenated, 32 + 8 bytes) followed by the
  payload. Entries must appear at strictly increasing offsets.

  Reference: nintoolbox project/src/lib-pvol.c (ExtractPVOLArchive /
  CreatePVOLArchive).

seq:
  - id: file_count
    type: u4
    doc: Number of table entries plus one; the real entry count is file_count - 1.
  - id: entries
    type: table_entry
    repeat: expr
    repeat-expr: file_count - 1

instances:
  entry_count:
    value: file_count - 1

types:
  table_entry:
    seq:
      - id: offset
        type: u4
      - id: length
        type: u4
    instances:
      name_part1:
        pos: offset
        size: 32
        type: strz
        encoding: ASCII
      name_part2:
        pos: offset + 0x20
        size: 8
        type: strz
        encoding: ASCII
      data:
        pos: offset + 0x28
        size: length
