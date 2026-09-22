meta:
  id: lzbin
  endian: le
doc: |
  LZBIN archive, ported from lib-lzbin.c/.h. A little-endian file table
  {u32 num_files} followed by one {u32 offset, u32 comp_size} pair per
  file; each entry's data lives at `offset` as a 4-byte skipped word
  followed by a raw LZ10/LZ11 stream (see
  nitro/lz10.ksy) `comp_size` bytes long. The reference scanner
  recognises this container purely from those structural constraints
  (there is no magic).

  Detection requires 1..4000 files, a complete table, and a first member
  whose offset and declared compressed range are in-file. It checks only
  that first member's stream byte for 0x10 or 0x11; later entries are
  checked individually during extraction. An out-of-range later entry is
  skipped. If LZ10/LZ11 decoding fails, its compressed bytes are extracted
  unchanged as fileNNN.lz. Successful members become fileNNN.dat, except
  decoded HBDF or HSDF magic becomes fileNNN.hbdf. These names are generated,
  not stored in the archive.

  The writer encodes every member as LZ10, writes a zero skipped word,
  and packs member records consecutively after the table. It does not
  preserve an original stream's LZ11 choice or skipped-word contents.
seq:
  - id: num_files
    type: u4
    doc: Number of eight-byte offset/size table entries.
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
        doc: Size of the LZ10/LZ11 stream, excluding the preceding four-byte word.
    instances:
      marker:
        pos: offset
        type: u4
        doc: Skipped four-byte word; zero in writer output.
      lz_magic:
        pos: offset + 4
        type: u1
        doc: Expected to be 0x10 or 0x11 (LZ10/LZ11).
      compressed_body:
        pos: offset + 4
        size: comp_size
        io: _root._io
        doc: Complete stored LZ10/LZ11 stream; decoding is not performed here.
