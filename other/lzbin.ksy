meta:
  id: lzbin
  endian: le
doc: |
  LZBIN archive, ported from lib-lzbin.c/.h. A little-endian file table
  {u32 num_files} followed by one {u32 offset, u32 comp_size} pair per
  file; each entry's data lives at `offset` as a 4-byte marker/padding
  byte (skipped) followed by a raw LZ10/LZ11 stream (see
  nitro/lz10.ksy) `comp_size` bytes long. The reference scanner
  recognises this container purely from those structural constraints
  (there is no magic).
seq:
  - id: num_files
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_files
types:
  entry:
    seq:
      - id: offset
        type: u4
        doc: File offset of this entry's 4-byte marker, immediately followed by its LZ10/LZ11 stream.
      - id: comp_size
        type: u4
        doc: Size of the LZ10/LZ11 stream (the marker byte's 4 bytes excluded).
    instances:
      marker:
        pos: offset
        type: u4
      lz_magic:
        pos: offset + 4
        type: u1
        doc: Expected to be 0x10 or 0x11 (LZ10/LZ11).
