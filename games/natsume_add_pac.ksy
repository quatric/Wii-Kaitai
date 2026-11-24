meta:
  id: natsume_add_pac
  title: Natsume "add" PAC archive (.pac)
  file-extension: pac
  endian: be
doc: |
  Natsume `add` PAC (Gintama: Yorozuya Chuubu - Tsukkomable Douga, Wii; layout
  per QuickBMS `add_pac.bms`, version <= 4). Big-endian on Wii, little-endian
  elsewhere. NUL-terminated names are stored behind the table. Members named
  `*z` (brresz, brtexz, anmz, ...) are Natsume `LZS\0` streams: u8 length bits
  at +5, u8 unit bits at +6 (8 or 16), u32 flag/match stream offset at +8, u32
  literal pool offset at +0xC, u32 unpacked size at +0x10, u8 length threshold
  at +0x19; the flag stream is 16-bit words (bit 0 first, 1 = literal unit from
  the pool); a match word is `(distance << length bits) | (length - threshold)`
  counted in units of unit-bits/8 bytes. The decoded member is stored without
  the trailing `z`.
seq:
  - id: magic
    contents: ['add', 0]
  - id: version
    type: u1
  - id: reserved0
    size: 3
  - id: table_offset
    type: u4
  - id: entry_size
    type: u4
    doc: 0x20.
  - id: num_entries
    type: u4
  - id: len_file
    type: u4
instances:
  entries:
    pos: table_offset
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: offset
        type: u4
      - id: len_data
        type: u4
      - id: zero0
        type: u4
      - id: timestamp
        type: u4
      - id: name_offset
        type: u4
      - id: reserved
        size: 12
    instances:
      name:
        pos: name_offset
        io: _root._io
        type: strz
        encoding: ASCII
      data:
        pos: offset
        io: _root._io
        size: len_data
