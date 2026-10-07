meta:
  id: packv2
  title: '"PACK" version 2 data archive (Ski and Shoot packfile.pak)'
  file-extension: pak
  endian: le
doc: |
  "PACK" version 2 archive used by Ski and Shoot / RTL Biathlon 2009 and six
  more Wii titles (`packfile.pak`). Verified on the 2,848-entry retail
  `packfile.pak` of Ski and Shoot.

  Flags `0x30` mean stored (`size == size2`); flags `0x77` mean packed
  (`size` = packed bytes, `size2` = unpacked bytes) with a bit-oriented LZ
  coder that nintoolbox does not decode yet -- such members are written
  unchanged as `<name>.packed`.
seq:
  - id: magic
    contents: 'PACK'
  - id: version
    type: u4
    doc: Always 2.
  - id: num_entries
    type: u4
  - id: table_end
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: size
        type: u4
        doc: Stored size (packed bytes for flags 0x77).
      - id: size2
        type: u4
        doc: Unpacked size; equal to `size` for stored members.
      - id: offset
        type: u4
      - id: name_offset
        type: u4
        doc: Absolute offset of a NUL-terminated `dir/file.ext` path.
      - id: crc
        type: u4
      - id: flags
        type: u4
        doc: '`0x30` stored, `0x77` packed.'
    instances:
      name:
        pos: name_offset
        type: strz
        encoding: ASCII
        io: _root._io
      body:
        pos: offset
        size: size
        io: _root._io
