meta:
  id: catcar
  file-extension: car
  endian: le
  title: Cat Daddy Games CDGaCube archive
doc: |
  Cat Daddy Games "CDGaCube" archive (`birthday.CAR` in Birthday Party
  Bash, Wii). All fields little-endian. The member table is followed by
  one NUL-terminated full path per entry, in entry order; members
  themselves are stored raw or as a bare zlib stream, detected by
  whether the stream at the member's offset ends exactly after its
  declared size.
seq:
  - id: magic
    type: str
    size: 8
    encoding: ASCII
    valid: '"CDGaCube"'
  - id: data_sector
    type: u4
    doc: First member's sector; the name table ends before this sector.
  - id: num_entries
    type: u4
  - id: entry_size
    type: u4
    valid: 24
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
instances:
  names:
    pos: _io.pos
    type: name_table(num_entries)
types:
  entry:
    seq:
      - id: flags
        type: u4
        enum: entry_kind
      - id: filetime
        type: u8
      - id: size
        type: u4
        doc: Bytes stored in the archive for this member.
      - id: name_index
        type: u4
        doc: Equal to this entry's own index.
      - id: sector
        type: u4
        doc: Member offset in the archive, in 2048-byte sectors.
    instances:
      ofs_body:
        value: sector * 2048
      body:
        io: _root._io
        pos: ofs_body
        size: size
        if: (flags.to_i & 0x30) == 0x20
  name_table:
    params:
      - id: count
        type: u4
    seq:
      - id: path
        type: strz
        encoding: ASCII
        repeat: expr
        repeat-expr: count
enums:
  entry_kind:
    0x10: root_dot
    0x20: file
    0x21: file_alt
    0x30: directory
