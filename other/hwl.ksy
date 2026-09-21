meta:
  id: hwl
  file-extension: idx
  endian: le
  title: Hyrule Warriors Legends (3DS) .idx member index
doc: |
  Index half of a Hyrule Warriors Legends (3DS) ".idx"/".bin" pair. The
  ".idx" is nothing but an array of {size, offset} records addressing the
  sibling ".bin" file; `size` 0 marks a hole (no member at that slot).
  There is no magic, header or name table -- callers must gate on the
  filename pair -- and offsets are only meaningful against the separate
  ".bin" file, which this definition cannot reference directly. Ported
  from lib-hwl.c's `ScanHWLegends`.
seq:
  - id: entries
    type: entry
    repeat: eos
types:
  entry:
    seq:
      - id: len_body
        type: u4
        doc: 0 marks an empty slot with no member.
      - id: ofs_body
        type: u4
        doc: Offset of the member into the sibling .bin file.
