meta:
  id: avdbl
  title: Avalanche Software .dbl / .mdb resource database (Disney's Bolt)
  file-extension: dbl
  endian: be
doc: |
  0x20-byte file header ("GCN\0" at +8, version 0x100 at +0x10), then chunks
  {u16 type, u16 flags, u32 size, u16 version, ...}: the header is 10 bytes, 0x2a
  with flag 2, 0x20 with flag 8 (0x40 with both), then size payload bytes.
  DB_TEXTURE_SET (type 0x82) payload D starts with the texture count and
  0x48-byte records from D+0x18.
seq:
  - id: file_header
    size: 0x20
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: type
        type: u2
      - id: flags
        type: u2
      - id: size
        type: u4
      - id: version
        type: u2
      - id: extra
        size: '((flags & 2) != 0 ? 0x20 : 0) + ((flags & 8) != 0 ? 0x10 : 0)'
      - id: payload
        size: size
  texture_record:
    seq:
      - id: name
        size: 0x20
        type: strz
        encoding: ASCII
      - id: format
        type: u4
        doc: GX format | 0x8000.
      - id: unused0
        size: 8
      - id: pixel_offset
        type: u4
      - id: width
        type: u2
      - id: height
        type: u2
      - id: unused1
        size: 2
      - id: palette_offset
        type: u4
      - id: palette_width
        type: u2
      - id: palette_height
        type: u2
      - id: unused2
        size: 1
