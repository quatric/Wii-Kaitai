meta:
  id: idd
  title: PlatinumGames IDD / EFF section container (MadWorld)
  file-extension: idd
  endian: be
doc: |
  Sections start with a 4-byte tag ("TEX", "EST", "MOD", "TUV", ...), u32
  count, u32 body offset (0x10). A TEX body B is {u32 id, u32 n, u32 table =
  0xc}, n pairs {texture record, palette header or 0} at B+table. Texture
  record (0x24): u16 width, u16 height, u32 GX format, u32 pixel offset (from
  B), then mip/wrap words. Palette header: u32 entries << 16, u32 TLUT format
  (0 IA8, 1 RGB565, 2 RGB5A3), u32 palette offset (from B).
seq:
  - id: magic
    size: 4
    doc: '"IDD\0" or "EFF\0".'
  - id: count
    type: u4
  - id: sections
    type: ref
    repeat: expr
    repeat-expr: count
types:
  ref:
    seq:
      - id: id
        type: u4
      - id: offset
        type: u4
    instances:
      section:
        pos: offset
        type: section
        io: _root._io
  section:
    seq:
      - id: tag
        size: 4
        type: str
        encoding: ASCII
      - id: count
        type: u4
      - id: body_offset
        type: u4
        doc: 0x10.
    instances:
      tex:
        pos: body_offset
        type: tex_body
        if: tag.substring(0, 3) == "TEX"
  tex_body:
    seq:
      - id: id
        type: u4
      - id: n
        type: u4
      - id: table
        type: u4
        doc: 0xc.
      - id: pairs
        type: tex_pair
        repeat: expr
        repeat-expr: n
  tex_pair:
    seq:
      - id: texture_record
        type: u4
      - id: palette_header
        type: u4
  texture_record:
    seq:
      - id: width
        type: u2
      - id: height
        type: u2
      - id: gx_format
        type: u4
      - id: pixel_offset
        type: u4
      - id: mip_wrap
        size: 0x24 - 12
  palette_header:
    seq:
      - id: entries_shifted
        type: u4
      - id: tlut_format
        type: u4
      - id: palette_offset
        type: u4
