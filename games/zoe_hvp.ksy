meta:
  id: zoe_hvp
  title: Zoe Mode / Ravenscourt HVP file pack (.hvp)
  file-extension: hvp
  endian: be
doc: |
  Zoe Mode / Ravenscourt `.hvp` file packs (Aladdin Magic Racer, X Factor,
  Knockout Party, Obscure: The Aftermath). Big-endian. Version `0x50000` carries
  a name pool after the header; version `0x40000` has none (then `name_offset`
  is meaningless).

  The table is a flat array of 28-byte records, record 0 being the root. A record
  with `flags & 4` is a directory: `a` = child count, `b` = index of the first
  child record. Otherwise it is a file: `a` = absolute data offset and `b` =
  stored size. `flags & 1` marks the member as an LZO1X stream (`size` is the
  unpacked length). The table sits right after the name pool and the data after
  the table.
seq:
  - id: version
    type: u4
    valid:
      any-of: [0x50000, 0x40000]
  - id: zero
    type: u4
  - id: count
    type: u4
  - id: table_checksum
    type: u4
  - id: pool_size
    type: u4
    if: version == 0x50000
  - id: name_pool
    size: pool_size
    if: version == 0x50000
    doc: NUL-terminated names; records point into it.
  - id: records
    type: record
    repeat: expr
    repeat-expr: count
types:
  record:
    seq:
      - id: name_hash
        type: u4
      - id: flags
        type: u4
      - id: crc
        type: u4
      - id: size
        type: u4
        doc: Unpacked size for files.
      - id: name_offset
        type: u4
        doc: Offset into the name pool.
      - id: a
        type: u4
        doc: Directory - child count. File - absolute data offset.
      - id: b
        type: u4
        doc: Directory - first child record. File - stored size.
    instances:
      is_directory:
        value: (flags & 4) != 0
      is_lzo:
        value: (flags & 1) != 0
      data:
        pos: a
        size: b
        io: _root._io
        if: not is_directory
