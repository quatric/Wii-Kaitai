meta:
  id: nxarc
  file-extension: nxarc
  endian: le
  title: Nintendo Switch NX Archive (RAXN)
doc: |
  Simple little-endian file archive: a fixed 32-byte header, a
  string-table block holding one NUL-terminated name per entry (entry 0
  is a pseudo string-table entry and carries no file), and a 32-byte
  descriptor per entry (64-bit size/offset/flag, low word only -- the
  reader treats these as always fitting in 32 bits and reads high and
  low words separately). `flag == 1` means the payload is zlib
  compressed.

  Reference: nintoolbox project/src/lib-nxarc.c (ExtractNXARCArchive /
  CreateNXARCArchive).
seq:
  - id: magic
    contents: "RAXN"
  - id: unk_04
    size: 8
  - id: ofs_names
    type: u4
  - id: header_size
    type: u4
  - id: num_files
    type: u4
  - id: block_size
    type: u4
instances:
  names:
    pos: ofs_names
    type: names_block
  entries:
    pos: header_size
    type: entry
    repeat: expr
    repeat-expr: num_files
types:
  names_block:
    doc: NUL-terminated names, one per entry (including the unused pseudo entry 0), back to back.
    seq:
      - id: name
        type: strz
        encoding: ASCII
        repeat: eos

  entry:
    doc: |
      32-byte descriptor. Entry 0 is the string-table pseudo entry and
      is skipped by the extractor. `size_lo`/`offset_lo` are the fields
      actually used; the high words are read too but never non-zero in
      practice.
    seq:
      - id: size_lo
        type: u4
      - id: size_hi
        type: u4
      - id: offset_lo
        type: u4
      - id: offset_hi
        type: u4
      - id: flag_lo
        type: u4
        enum: compression
      - id: flag_hi
        type: u4
    instances:
      body:
        pos: offset_lo
        size: size_lo
        if: offset_lo != 0 or size_lo != 0
enums:
  compression:
    0: none
    1: zlib
