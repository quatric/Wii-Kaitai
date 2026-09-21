meta:
  id: catcar
  file-extension: car
  endian: le
  title: Cat Daddy Games CDGaCube archive
doc: |
  A flat file archive used by Cat Daddy Games' "CDGaCube" engine, seen as
  `birthday.CAR` in Birthday Party Bash (Wii). All fields are little-endian.

  The header gives an entry count and a fixed 24-byte entry stride; right
  after the header comes the entry table, and right after that -- ending
  exactly where the first member's data begins -- a name pool of one
  NUL-terminated full path per entry, in entry order (`name_index` doubles
  as a cross-check: it always equals the entry's own index).

  Each entry's `flags` field doubles as a node-type tag: `0x10` marks the
  root's own `.`/`..` pseudo-entries, `0x30` marks a directory, and
  `0x20`/`0x21` mark a file. Only file entries (`flags & 0x30 == 0x20`)
  carry real data; directory entries have no member bytes of their own.

  A file member's bytes are stored at `sector * 2048`, either raw or as a
  bare zlib stream (recognised by extractors as such when a zlib stream
  starting at that offset decodes to exactly `size` bytes); this format
  itself carries no explicit "is compressed" flag.
seq:
  - id: magic
    contents: "CDGaCube"
  - id: data_sector
    type: u4
    doc: |
      Sector index of the first member's data. The name pool ends exactly
      before this sector, so it also bounds the name pool's size.
  - id: num_entries
    type: u4
  - id: len_entry
    type: u4
    doc: Size of one entry record; always 24 in every sample seen.
  - id: entries
    type: entry(_index)
    repeat: expr
    repeat-expr: num_entries
instances:
  ofs_names:
    value: 0x14 + len_entry * num_entries
    doc: Byte offset where the NUL-terminated name pool begins.
  names:
    pos: ofs_names
    type: strz
    encoding: ASCII
    repeat: expr
    repeat-expr: num_entries
    doc: One full path per entry, in entry order.
types:
  entry:
    params:
      - id: idx
        type: u4
    seq:
      - id: flags
        type: u4
        doc: |
          Node-type tag: `0x10` = root `.`/`..`, `0x30` = directory,
          `0x20`/`0x21` = file.
      - id: filetime
        type: u8
        doc: Windows FILETIME; ignored by extractors.
      - id: size
        type: u4
        doc: Bytes stored in the archive for this member.
      - id: name_index
        type: u4
        doc: Index into the name pool; always equal to this entry's own index.
      - id: sector
        type: u4
        doc: Member's data offset, in 2048-byte sectors.
    instances:
      is_file:
        value: (flags & 0x30) == 0x20
      is_directory:
        value: (flags & 0x30) == 0x30
      ofs_data:
        value: sector * 2048
      name:
        value: _root.names[idx]
      data:
        io: _root._io
        pos: ofs_data
        size: size
        if: is_file
