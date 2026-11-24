meta:
  id: datl
  title: Winning Post World .datl
  file-extension: datl
  endian: be
doc: |
  Winning Post World (Wii) `*.datl`. The table ends at the first zero offset;
  each member is a headerless Okumura LZSS stream (LSB-first flags, zero-filled
  4096-byte ring, start 0xFEE) that inflates to a BRRES.
seq:
  - id: magic
    type: u4
    doc: 0x1000.
  - id: entries
    type: entry
    repeat: until
    repeat-until: _.offset == 0
types:
  entry:
    seq:
      - id: len_compressed
        type: u4
      - id: len_decompressed
        type: u4
      - id: offset
        type: u4
