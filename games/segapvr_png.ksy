meta:
  id: segapvr_png
  title: Sonic Team Wii-port PVR texture (XIBG / TRVP)
  file-extension: pvr
  endian: be
doc: |
  Illvelo / Radirgy Noa. "XIBG" (= GBIX reversed) {u32 BE 8, u64 global index},
  "TRVP" (= PVRT reversed) {u32 BE size, u32 BE type, u16 BE width, u16 BE
  height}, texels at 0x20. type = (data kind << 8) | pixel format. Kind 0x45 =
  raw 4x4-tiled BE 16-bit texels, pixel format 0 ARGB1555, 1 RGB565, 2 ARGB4444;
  0x4e = GX CMPR; 0x48 = 16-entry ARGB1555 palette at 0x20 then 4-bit indices in
  8x8 tiles.
seq:
  - id: gbix_tag
    contents: XIBG
  - id: gbix_size
    type: u4
    doc: 8.
  - id: global_index
    type: u8
  - id: pvrt_tag
    contents: TRVP
  - id: size
    type: u4
  - id: type
    type: u4
  - id: width
    type: u2
  - id: height
    type: u2
  - id: texels
    size-eos: true
