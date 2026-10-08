meta:
  id: pda_bra
  title: Messiah-engine PDA archive (.bra)
  file-extension: bra
  endian: le
doc: |
  Messiah-engine `PDA\0` archive (Gummy Bears: Magical Medallion / MiniGolf).
  Members follow the 16-byte header back to back; each is a 16-byte member
  header and a raw deflate stream of `stored_size` bytes. A table at
  `table_offset` lists the names and offsets. Names are NUL- or
  0xCC-padded, `\` separated.

  The same 16-byte member header is used by the raw-deflate members that
  nintoolbox recovers from Messiah `3df ` containers (see `deflate_member`).
seq:
  - id: magic
    contents: ['PDA', 0]
  - id: version
    type: u4
    doc: 2.
  - id: table_offset
    type: u4
  - id: count
    type: u4
instances:
  members:
    pos: 16
    type: member
    repeat: expr
    repeat-expr: count
  table:
    pos: table_offset
    type: table_entry
    repeat: expr
    repeat-expr: count
types:
  member:
    seq:
      - id: header
        type: deflate_member_header
      - id: deflate_stream
        size: header.stored_size
  deflate_member_header:
    seq:
      - id: size
        type: u4
        doc: Unpacked size.
      - id: stored_size
        type: u4
      - id: crc
        type: u4
      - id: flags
        type: u4
        doc: Seen as `0x????0006`.
  table_entry:
    seq:
      - id: time
        type: u4
      - id: crc
        type: u4
      - id: member_size
        type: u4
        doc: '`stored_size + 16`.'
      - id: size
        type: u4
      - id: name_len
        type: u2
      - id: flags
        type: u2
      - id: offset
        type: u4
      - id: name
        size: name_len
        doc: NUL / 0xCC padded, backslash separated.
