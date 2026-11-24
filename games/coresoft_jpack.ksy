meta:
  id: coresoft_jpack
  title: Coresoft JPack archive (.pak)
  file-extension: pak
  endian: be
doc: |
  Coresoft `JPack` `.pak` (Fantasy Aquarium World `loaddata.pak` /
  `fishdata.pak`, other Coresoft/Destineer Wii titles). Members are zlib
  streams (stored as is when the stream has no zlib header). Names are not
  in the archive: the low 32 bits of `name_hash` match the `Hash: xxxxxxxx;
  File: a\b.wtx` lines of the `jpack_<pak>.log` build log next to it.
seq:
  - id: version
    type: u4
    doc: 1.
  - id: num_entries
    type: u4
  - id: copyright
    size: 0x18
    type: strz
    encoding: ASCII
    doc: '"(C)2008 Coresoft, Inc."'
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: name_hash
        type: u8
      - id: flags
        type: u4
        doc: alignment << 16 | 0x20.
      - id: len_data
        type: u4
      - id: offset
        type: u4
    instances:
      data:
        pos: offset
        io: _root._io
        size: len_data
