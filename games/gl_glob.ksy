meta:
  id: gl_glob
  title: Green Lantern GLOB data pack (.glob)
  file-extension: glob
  endian: be
doc: |
  `GLOB` resource pack (Green Lantern: Rise of the Manhunters, Wii; `.glob` data
  plus `.name.glob` name table, 422 packs). The data file lists `{u32 id, u32
  offset, u32 size}` per resource; ids match the name file (see
  `gl_glob_names`) and the data is stored back to back after the table. An end
  sentinel has id 0x7FFFFFFF.
seq:
  - id: magic
    contents: GLOB
  - id: count
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: id
        type: u4
      - id: offset
        type: u4
      - id: len_data
        type: u4
