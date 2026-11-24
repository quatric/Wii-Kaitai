meta:
  id: retropak
  title: Retro Studios PAK version 2 (MP3, DKC Returns)
  file-extension: pak
  endian: be
doc: |
  {u32 2, u32 0x40, 0x38 bytes hash}, u32 section count + {tag, size} pairs,
  then 0x40-aligned STRG {u32 n; n * {cstr name, fourcc type, u64 id}}, RSHD
  {u32 n; n * {u32 compressed, fourcc, u64 id, u32 size, u32 offset}} and DATA.
  A compressed resource is "CMPD", u32 blocks, blocks * {u32 (flags << 29 |
  compressed size), u32 size}; equal sizes = stored, otherwise zlib (DKCR) or a
  run of {u16 length, LZO1X data} pieces of up to 0x4000 bytes.
seq:
  - id: version
    type: u4
    doc: 2.
  - id: x40
    type: u4
  - id: hash
    size: 0x38
  - id: section_count
    type: u4
  - id: sections
    type: section
    repeat: expr
    repeat-expr: section_count
  - id: rest
    size-eos: true
types:
  section:
    seq:
      - id: tag
        size: 4
        type: str
        encoding: ASCII
      - id: size
        type: u4
  cmpd:
    seq:
      - id: magic
        contents: CMPD
      - id: block_count
        type: u4
      - id: blocks
        type: block
        repeat: expr
        repeat-expr: block_count
  block:
    seq:
      - id: flags_compressed_size
        type: u4
        doc: flags << 29 | compressed size.
      - id: size
        type: u4
