meta:
  id: nut
  file-extension: nut
  title: Bandai Namco NUT texture package (Smash Bros. for 3DS / Wii U)
doc: |
  Namco Texture container: a magic/version/count header followed by
  per-texture 32-byte (or larger) descriptors, each carrying its own
  pixel data pointer. Endianness is signalled by the magic variant
  ("NTP3"/"NUT\0" little-endian vs. "3PTN"/"\0TUN" big-endian) and cross
  checked against a plausible (version, count) pair.

  This models the little-endian ("NTP3") variant; the reader also
  accepts the byte-reversed big-endian forms by re-reading the same
  fields with the opposite endianness.

  Reference: nintoolbox project/src/lib-nut.c (ScanNUT).
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
    valid:
      any-of: ['"NTP3"', '"NUT\0"']
  - id: version
    type: u2le
  - id: num_textures
    type: u2le
  - id: reserved
    size: 8
  - id: textures
    type: texture_header
    repeat: expr
    repeat-expr: num_textures
types:
  texture_header:
    doc: |
      32-byte fixed header; `header_size` (when >=32) gives the real
      stride to this texture's pixel data, otherwise 48 bytes is
      assumed. `data_offset`, when consistent with the running file
      position, takes precedence over both.
    seq:
      - id: len_total
        type: u4le
      - id: len_palette
        type: u4le
      - id: len_data
        type: u4le
      - id: header_size
        type: u2le
      - id: len_name
        type: u2le
      - id: width
        type: u2le
      - id: height
        type: u2le
      - id: num_mips
        type: u4le
      - id: pixel_format
        type: u4le
      - id: data_offset
        type: u4le
