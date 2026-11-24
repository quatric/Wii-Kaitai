meta:
  id: ralph_glob
  title: Wreck-It Ralph GLOB pack (.glob)
  file-extension: glob
  endian: be
doc: |
  Disney Wreck-It Ralph `*.glob`. Data start is `0x1C + 12 * entries`; the last
  entry has id 0x7FFFFFFF and size 0 and ends at EOF; 8 footer bytes follow the
  table.
seq:
  - id: magic
    contents: GLOB
  - id: num_entries_with_terminator
    type: u4
  - id: unknown0
    type: u4
  - id: data_start
    type: u4
  - id: unknown1
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries_with_terminator
types:
  entry:
    seq:
      - id: id
        type: u4
      - id: offset
        type: u4
      - id: len_data
        type: u4
