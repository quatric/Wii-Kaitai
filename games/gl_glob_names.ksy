meta:
  id: gl_glob_names
  title: Green Lantern GLOB name table (.name.glob)
  file-extension: glob
  endian: be
doc: |
  Name table for `gl_glob` data packs. Per resource `{u32 id, u32 offset of the
  name, u32 length (with the terminating NUL)}`, plus an end sentinel with id
  0x7FFFFFFF. Names look like `Textures/Maps/Coastcity/c_sidewalk.gaftx`.
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
      - id: name_offset
        type: u4
      - id: len_name
        type: u4
    instances:
      name:
        pos: name_offset
        io: _root._io
        type: strz
        size: len_name
        encoding: ASCII
