meta:
  id: rw_txd_gc
  title: RenderWare GameCube/Wii texture dictionary (.txd)
  file-extension: txd
  endian: le
doc: |
  Chunk 0x16 {struct 0x01 {u16 count, u16 device}, count x native texture 0x15,
  extension 0x03}. Native texture struct holds (payload-relative): platform u32
  BE @0 (6 = GC), name[32] @0x18, mask name[32] @0x38, raster format u32 BE
  @0x58, width/height u16 BE @0x5c, depth u8 @0x60, level count u8, GX format u8
  @0x62 (9 C8, 8 C4, 0xe CMPR, 5 RGB5A3), pixels from @0x6c.
seq:
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: type
        type: u4
      - id: size
        type: u4
      - id: version
        type: u4
      - id: body
        size: size
  native_texture:
    seq:
      - id: platform
        type: u4be
      - id: unk4
        size: 0x14
      - id: name
        size: 32
        type: strz
        encoding: ASCII
      - id: mask_name
        size: 32
        type: strz
        encoding: ASCII
      - id: raster_format
        type: u4be
      - id: width
        type: u2be
      - id: height
        type: u2be
      - id: depth
        type: u1
      - id: levels
        type: u1
      - id: gx_format
        type: u1
      - id: unk63
        size: 0x6c - 0x63
      - id: pixels
        size-eos: true
