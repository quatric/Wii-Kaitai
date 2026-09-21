meta:
  id: g1t
  file-extension: g1t
  endian: le
  title: Koei Tecmo G1T texture container
doc: |
  Texture container used by Koei Tecmo titles. Ported from nintoolbox's
  `lib-g1t.c` (`ExtractG1TArchive`). Two platform variants share the same
  field layout but differ in byte order and byte-reversed magic:

  - 3DS (ARM): magic `GT1G`, little-endian fields.
  - Wii U (PowerPC): magic `G1TG`, big-endian fields (this is `GT1G`
    reversed).

  This definition parses the little-endian 3DS variant; for the Wii U
  variant re-parse the same bytes with `endian: be` and magic `G1TG`.
  A separate, unrelated wrapper (`.g1t.gz`, magic `u4 0x10000`) chunks a
  G1T container into zlib streams and is not modeled here.
seq:
  - id: magic
    contents: "GT1G"
  - id: unknown_04
    size: 4
  - id: total_size
    type: u4
    doc: Total file size; must equal the file's actual length.
  - id: table_offset
    type: u4
    doc: Offset of the per-texture relative-offset table.
  - id: count
    type: u4
  - id: platform
    type: u4
instances:
  offset_table:
    pos: table_offset
    type: u4
    repeat: expr
    repeat-expr: count
types:
  header_body:
    seq:
      - id: mip_and_flags
        type: u1
        doc: High nibble = mip level count (0 means 1); low nibble unused here.
      - id: format
        type: u1
        doc: "0x09 = RGBA8 (PICA tiled), 0x47 = ETC1, 0x48 = ETC1A4; other values are platform-specific (e.g. Wii U GX2) and left raw."
      - id: dims
        type: u1
        doc: High nibble = log2(width), low nibble = log2(height).
      - id: unknown
        type: u1
