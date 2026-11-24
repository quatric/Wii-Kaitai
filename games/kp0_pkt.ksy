meta:
  id: kp0_pkt
  title: KP0 package (.pkt)
  file-extension: pkt
  endian: le
doc: |
  `KP0` package (Power Punch, Wii; also nested inside other packages).
  Entries sit behind a 16-byte header and are followed by a string table of
  NUL-terminated names (`name_offset` is relative to the end of the entry
  table); `data_start` is where member data begins and each entry's `offset`
  is relative to it.

  Flags (low 16 bits): 1 = raw; 0x1E01 / 0x1C01 = compressed, the data
  carrying a Nintendo BIOS header (first byte 0x10 LZ10, 0x11 LZ11, 0x30 RLE);
  2 / 3 = external reference by path, no data.
seq:
  - id: magic
    contents: ['KP0', 0]
  - id: count
    type: u4
  - id: data_start
    type: u4
  - id: entry_size
    type: u4
    doc: 24.
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: name_offset
        type: u4
      - id: stored_size
        type: u4
      - id: offset
        type: u4
      - id: flags
        type: u4
      - id: unpacked_size
        type: u4
      - id: name_length_plus_1
        type: u4
    instances:
      name:
        pos: 16 + _root.count * 24 + name_offset
        type: strz
        encoding: ASCII
      data:
        pos: _root.data_start + offset
        size: stored_size
        if: (flags & 0xffff) < 2
        doc: Absent for external references (flags 2 / 3).
