meta:
  id: gpak
  file-extension: pak
  endian: be
  title: Nameless "GPAK" archive
doc: |
  Flat, nameless archive: a 16-byte header holding the member count (with a
  reserved zero at offset 8) followed by one 16-byte (offset, size) record
  per member starting at offset 0x10. Member data itself follows the table.
  Ported from lib-gpak.c's `ScanGPAK`/`CreateGPAK`; readers name members
  ordinally ("file_%04u.bin") since the format carries no names.
seq:
  - id: num_entries
    type: u4
  - id: reserved
    type: u4
    doc: Always 0 in every known sample.
  - id: reserved2
    type: u8
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: ofs_body
        type: u4
      - id: len_body
        type: u4
      - id: reserved
        type: u8
    instances:
      body:
        io: _root._io
        pos: ofs_body
        size: len_body
