meta:
  id: lspk
  application: Skylanders (Toys for Bob / Vicarious Visions engine)
  endian: be
doc: |
  LSPK archive, ported from lib-lspk.c/.h. Split into two sibling files:
  a small index (".pkh") and a data blob (".pk"); this definition
  models the index. The index is {u32 entry_count} then one 16- or
  24-byte row per entry (row size is detected structurally from
  (pkh_size - 4) / entry_count): the 16-byte row packs a 32-bit file
  offset, the 24-byte row a full 64-bit offset. `com_size` of 0 means
  the entry is stored uncompressed in the ".pk" file at `dec_size`
  bytes; a nonzero `com_size` means the stored span is that many
  (presumably LZ-compressed) bytes, decompressing to `dec_size`.
seq:
  - id: num_entries
    type: u4
  - id: entries
    type: entry16
    repeat: expr
    repeat-expr: num_entries
    doc: |
      Assumes the common 16-byte row size. For the 24-byte/64-bit-offset
      variant, reparse the same bytes as `entry24` instead (row size is
      `(pkh_size - 4) / num_entries`, either 16 or 24).
types:
  entry16:
    doc: 16-byte index row with a 32-bit data offset.
    seq:
      - id: hash
        type: u4
        doc: Hash of the entry's file name (hex-named files hash to their literal value).
      - id: offset
        type: u4
        doc: Byte offset of this entry's data within the sibling ".pk" file.
      - id: dec_size
        type: u4
        doc: Decompressed size.
      - id: com_size
        type: u4
        doc: Compressed size stored in the ".pk" file; 0 = stored uncompressed at dec_size bytes.
  entry24:
    doc: 24-byte index row with a full 64-bit data offset.
    seq:
      - id: hash
        type: u4
      - id: unused
        type: u4
      - id: offset_hi
        type: u4
      - id: offset_lo
        type: u4
      - id: dec_size
        type: u4
      - id: com_size
        type: u4
    instances:
      offset:
        value: (offset_hi.as<u8> << 32) | offset_lo
