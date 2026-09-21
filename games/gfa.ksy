meta:
  id: gfa
  file-extension: gfa
  endian: le
  title: Nintendo 3DS GFAC archive (.gfa)
doc: |
  Compressed archive format, magic `GFAC`, ported from nintoolbox's
  `lib-gfa.c` (`ScanGFA`). The header gives absolute offsets to an
  entry-info table (which is itself compressed, wrapped in a `GFCP`
  block) and to the raw payload region.

  The `GFCP` block right after `info_offset` carries the compression id
  (1 = BPE, 2 or 3 = raw LZ10) plus the decompressed size of the entry
  table; decompressing it yields `entry_count` followed by 16-byte
  records: an opaque per-entry value (not a recomputable name hash, see
  `lib-gfa.h`), a 24-bit name-string offset, a file size and a data
  offset (relative to `data_offset`).
seq:
  - id: magic
    contents: "GFAC"
  - id: unknown_04
    size: 8
  - id: info_offset
    type: u4
  - id: unknown_10
    size: 4
  - id: data_offset
    type: u4
  - id: data_size
    type: u4
instances:
  info_block:
    pos: info_offset
    type: gfcp_block
types:
  gfcp_block:
    seq:
      - id: magic
        contents: "GFCP"
      - id: unknown_04
        size: 4
      - id: compression
        type: u4
        doc: 1 = BPE, 2 or 3 = raw LZ10.
      - id: decompressed_size
        type: u4
      - id: compressed_size
        type: u4
      - id: compressed_data
        size: compressed_size
        doc: |
          Compressed entry-info table (`entry_count` u32 followed by
          16-byte entry records); decompress with the algorithm named by
          `compression` to access it. Not expanded here.
