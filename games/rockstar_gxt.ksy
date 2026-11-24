meta:
  id: rockstar_gxt
  title: Rockstar Leeds GXT text table (.gxt)
  file-extension: gxt
  endian: be
doc: |
  Rockstar Leeds `GXT` text table (Manhunt 2, Wii; sizes big endian, strings
  UTF-16BE). `TKEY` holds 20-byte entries from 0xC (`name[12]`, u32 attribute, u32
  end offset of the entry's string inside the `TDAT` block), followed at `8 +
  size` by `TDAT` (`{size, UTF-16BE NUL-terminated strings back to back}`). The
  strings are not stored in key order, so a string starts after the previous NUL
  before its end offset.
seq:
  - id: tkey_tag
    contents: TKEY
  - id: len_tkey
    type: u4
  - id: tkey
    type: tkey_body
    size: len_tkey
types:
  tkey_body:
    seq:
      - id: unknown
        type: u4
      - id: entries
        type: entry
        repeat: eos
  entry:
    seq:
      - id: name
        size: 12
        type: strz
        encoding: ASCII
      - id: attribute
        type: u4
      - id: end_offset
        type: u4
