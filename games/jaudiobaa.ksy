meta:
  id: jaudiobaa
  title: Nintendo JAudio BAA sound archive (.baa)
  file-extension: baa
  endian: be
doc: |
  Twilight Princess Z2Sound.baa and other JAudio2 games; waves live in the
  ".aw" files. Chunk records until ">_AA": "bst " / "bstn" / "bsc " {start,
  end}, "bfca" {start}, "bnk " {wsys id, offset}, "ws  " {id, offset, 0}. A
  WSYS {"WSYS", size, id, u32 +0x0c, WINF offset @+0x10, WBCT offset @+0x14};
  WINF {"WINF", count, group offsets}, each group {char name[0x70] (the .aw
  file), u32 waves, wave offsets}, all relative to the WSYS. A wave record is
  0x2c bytes {u8 0xcc, u8 format (0 AFC 4 bit, 1 AFC 2 bit, 2 PCM8, 3 PCM16),
  u8 key, ...}.
seq:
  - id: magic
    contents: "AA_<"
  - id: chunks
    type: chunk
    repeat: until
    repeat-until: _.tag == ">_AA"
types:
  chunk:
    seq:
      - id: tag
        size: 4
        type: str
        encoding: ASCII
      - id: body
        type:
          switch-on: tag
          cases:
            '"bst "': range
            '"bstn"': range
            '"bsc "': range
            '"bfca"': start_only
            '"bnk "': id_offset
            '"ws  "': id_offset_zero
  range:
    seq:
      - id: start
        type: u4
      - id: end
        type: u4
  start_only:
    seq:
      - id: start
        type: u4
  id_offset:
    seq:
      - id: id
        type: u4
      - id: offset
        type: u4
  id_offset_zero:
    seq:
      - id: id
        type: u4
      - id: offset
        type: u4
      - id: zero
        type: u4
  wsys:
    seq:
      - id: magic
        contents: WSYS
      - id: size
        type: u4
      - id: id
        type: u4
      - id: unk0c
        type: u4
      - id: winf_offset
        type: u4
      - id: wbct_offset
        type: u4
