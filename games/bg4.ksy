meta:
  id: bg4
  file-extension: bg4
  endian: le
  title: Mario & Luigi Paper Jam (3DS) BG4 archive
doc: |
  A small flat archive used by *Mario & Luigi: Paper Jam*. Fixed 16-byte
  header, then a table of fixed-size entries, then a NUL-terminated name
  blob. An entry's offset has its top bit set when the member is BLZ
  ("backward LZSS", the same DS/3DS ARM-binary compression as `blz.ksy`)
  compressed; the bit is masked off to get the real file offset. An
  offset of 0 marks an unused slot.
seq:
  - id: magic
    contents: [0x42, 0x47, 0x34, 0x00]
  - id: dummy1
    type: u2
  - id: num_entries
    type: u2
  - id: ofs_data
    type: u4
    doc: Start of the payload region (not otherwise needed to parse the table).
  - id: dummy2
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
  - id: names
    size-eos: true
    doc: NUL-terminated names, indexed by each entry's `ofs_name`.
types:
  entry:
    seq:
      - id: ofs_body_raw
        type: u4
        doc: |
          Bit 31 set means the member is BLZ-compressed; the low 31 bits
          are the file offset. Zero means the slot is unused.
      - id: len_body
        type: u4
        doc: |
          Size of the stored (possibly BLZ-compressed) member; the
          decompressed size is not recorded here.
      - id: crc
        type: u4
      - id: ofs_name
        type: u2
        doc: Offset into the name blob, relative to the byte right after the entry table.
    instances:
      is_used:
        value: ofs_body_raw != 0
      is_compressed:
        value: (ofs_body_raw & 0x80000000) != 0
      ofs_body:
        value: ofs_body_raw & 0x7fffffff
      body:
        io: _root._io
        pos: ofs_body
        size: len_body
        if: is_used
      name:
        io: _root._io
        pos: 16 + _root.num_entries.as<u4> * 14 + ofs_name
        type: strz
        encoding: ASCII
        if: is_used
